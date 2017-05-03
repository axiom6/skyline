
$     = require( 'jquery'       )
Alloc = require( 'js/res/Alloc' )

class Book

  module.exports = Book

  constructor:( @stream, @store, @Data, @room, @res, @pay, @pict ) ->
    @rooms    = @room.rooms
    @roomUIs  = @room.roomUIs
    @myDays   =  0
    @today    = new Date()
    @monthIdx = @today.getMonth()
    @monthIdx = if 4 <=  @monthIdx and @monthIdx <= 9 then @monthIdx else 4
    @year     = 2017
    @month    = @Data.months[@monthIdx]
    @numDays  = 15
    @begMay   = 15
    @begDay   = if @month is 'May' then @begMay else 1
    @$cells   = []
    @totals   = 0
    @method   = 'site'

  ready:() ->
    $('#Book'   ).empty()
    $('#Pays'   ).empty()
    $('#Book'   ).append( @bookHtml()  )
    $('#Insts'  ).append( @instructHtml() )
    $('#Inits'  ).append( @initsHtml() )
    $('#Rooms'  ).append( @roomsHtml(@year,@monthIdx,@begDay,@numDays) )
    $('#Guest'  ).append( @guestHtml() )
    $('.guests' ).change( @onGuests  )
    $('.pets'   ).change( @onPets    )
    $('#Months' ).change( @onMonth   )
    $('#Days'   ).change( @onDay     )
    $('#Pop'    ).click(  @onPop     )
    $('#Err'    ).click(  @onErr     )
    $('#GoToPay').click(  @onGoToPay ) # .prop('disabled',true)
    $('#Navb').hide()
    $('#Book').show()
    @roomsJQuery()

  bookHtml:() ->
    """
    <div id="Make" class="Title">Make Your Reservation</div>
    <div id="Insts"></div>
    <div id="Inits"></div>
    <div id="Rooms"></div>
    <div id="Guest"></div>
    """

  instructHtml:() ->
    """
    <div   class="Instruct">
      <div>1. Select Month and Day of Arrival 2. Then for each Room Select:</div>
      <div style="padding-left:16px;">3. Number of Guests 4. Number of Pets 5. Click the Days</div>
      <div>6. Enter Contact Information: First Last Names, Phone and EMail</div>
    </div>
    """

  initsHtml:() ->
    htm  = """<label for="Months" class="InitIp">Start: #{ @htmlSelect( "Months", @Data.season, @month,  'months' ) }</label>"""
    htm += """<label for="Days"   class="InitIp">       #{ @htmlSelect( "Days",   @Data.days,   @begDay, 'days'   ) }</label>"""
    htm += """<label class="InitIp">&nbsp;&nbsp;#{@year}</label>"""
    htm += """<span  id="Pop" class="Test">Pop</span>"""
    htm += """<span  id="Err" class="Test">Err</span>"""
    htm

  seeRoom:( roomId, room ) ->
    #"""<a href="rooms/#{roomId}.html" id="#{roomId}L">#{room.name}</a>"""
    room.name

  roomsHtml:( year, monthIdx, begDay, numDays ) ->
    weekdayIdx  = new Date( year, monthIdx, 1 ).getDay()
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th></th><th></th><th></th>"""
    for day in [1..@numDays]
      weekday = @Data.weekdays[(weekdayIdx+@begDay+day-2)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Price</th>"
    for day in [1..@numDays]
      htm += "<th>#{@dayMonth(day)}</th>"
    htm += "<th>Total</th></tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td class="td-left">#{@seeRoom(roomId,room)}</td><td class="guests">#{@g(roomId)}</td><td class="pets">#{@p(roomId)}</td><td id="#{roomId}M" class="room-price">#{'$'+@calcPrice(roomId)}</td>"""
      for day in [1..numDays]
        htm += @createCell( roomId, room, @toDateStr(day) )
      htm += """<td class="room-total" id="#{roomId}T"></td></tr>"""
    htm += """<tr>"""
    htm += """<td></td>""" for day in [1..@numDays+4]
    htm += """<td class="room-total" id="Totals">&nbsp;</td></tr>"""
    htm += "</tbody></table>"
    htm

  guestHtml:() ->
    phPtn = "\d{3} \d{3} \d{4}" # pattern="#{phPtn}"
    """
    <form autocomplete="on" method="POST" id="FormName">
      <div id="Names">
        <span class="SpanIp">
          <label for="First" class="control-label">First Name</label>
          <input id= "First" type="text" class="input-lg form-control" autocomplete="given-name" required>
          <div   id= "FirstER" class="NameER">* Required</div>
        </span>

        <span class="SpanIp">
          <label for="Last" class="control-label">Last Name</label>
          <input id= "Last" type="text" class="input-lg form-control" autocomplete="family-name" required>
          <div   id= "LastER" class="NameER">* Required</div>
        </span>

        <span class="SpanIp">
          <label for="Phone" class="control-label">Phone</label>
          <input id= "Phone" type="tel" class="input-lg form-control" placeholder="••• ••• ••••"  pattern="#{phPtn}" required>
          <div   id= "PhoneER" class="NameER">* Required</div>
        </span>

        <span class="SpanIp">
          <label for="EMail"   class="control-label">Email</label>
          <input id= "EMail" type="email" class="input-lg form-control" autocomplete="email" required>
          <div   id= "EMailER" class="NameER">* Required</div>
        </span>
      </div>
      <div id="GoToDiv" style="text-align:center;">
       <button class="btn btn-primary" type="submit" id="GoToPay">Go To Confirmation and Payment</button>
      </div>
    </form>
    """

  isValid:( name, test, testing=false ) ->
    value = $('#'+name).val()
    valid = Util.isStr( value )
    if testing
      $('#'+name).val(test)
      value = test
      valid = true
    #$('#'+name+'ER').show() if not valid
    [value,valid]

  getCust( testing=false ) ->
    [first,fv] = @isValid('First', 'Samuel',      testing )
    [last, lv] = @isValid('Last',  'Hosendecker', testing )
    [phone,pv] = @isValid('Phone', '3037977129',  testing )
    [email,ev] = @isValid('EMail', 'Thomas.Edmund.Flaherty@gmail.com', testing )
    tv   = @totals > 0
    cust = @res.createCust( first, last, phone, email, "site" )
    [tv,fv,lv,pv,ev,cust]

  onGoToPay:( e ) =>
    e.preventDefault() if e?
    [tv,fv,lv,pv,ev,cust] = @getCust()
    if tv and fv and lv and pv and ev
      $('.NameER').hide()
      $('#Book').hide()
      res       = @createRoomRes()
      res.cust  = cust
      res.total = @totals
      #@res.add( res.resId, res )
      @pay.showConfirmPay(  res )
    else
      alert( @onGoToMsg( tv,fv,lv,pv,ev ) )
    return

  onGoToMsg:( tv,fv,lv,pv,ev ) ->
    msg  = ""
    msg += "Total is 0\n"           if not tv
    msg += "Need to Click Rooms\n"  if not tv
    msg += "Enter First Name\n"     if not fv
    msg += "Enter Last  Name\n"     if not lv
    msg += "Enter Phone Number\n"   if not pv
    msg += "Enter Email\n"          if not ev
    msg

  createCell:( roomId, roomRm, date ) ->
    roomUI   = @roomUIs[roomId]
    statusRm = @room.dayBookedRm( roomRm, date )
    statusUI = @room.dayBookedUI( roomUI, date )
    status   = if statusRm isnt 'free' then statusRm else statusUI
    """<td id="R#{roomId+date}" class="room-#{status}" data-status="#{status}"></td>"""

  roomsJQuery:() ->
    for $cell in @$cells
        $cell.unbind( "click" )
    @$cells = []
    for roomId, roomUI of @roomUIs
      roomUI.$ = $('#'+roomId) # Keep jQuery out of room database table
      for day in [1..@numDays]
        date  = @toDateStr(day)
        $cell = $('#R'+roomId+date)
        $cell.click( (event) => @onCellBook(event) )
        @$cells.push( $cell )
        @updateTotal( roomId )
    return

  calcPrice:( roomId ) =>
    roomUI = @roomUIs[roomId]
    guests = roomUI.resRoom.guests
    pets   = roomUI.resRoom.pets
    price  = @rooms[roomId][guests]+pets*@Data.petPrice
    roomUI.resRoom.price = price
    price

  updatePrice:(   roomId ) =>
    $('#'+roomId+'M').text("#{'$'+ @calcPrice(roomId) }")
    @updateTotal( roomId )
    return

  updateTotal:( roomId ) ->
    price = @calcPrice( roomId )
    room  = @roomUIs[roomId]
    room.resRoom.total = price * room.numDays
    text = if room.resRoom.total is 0 then '' else '$'+room.resRoom.total
    $('#'+roomId+'T').text(text)
    @updateTotals()
    return

  updateTotals:() ->
    @totals = 0
    for own roomId, room of @roomUIs
      @totals += room.resRoom.total
    text = if @totals is 0 then '' else '$'+@totals
    $('#Totals').text(text)
    $('#GoToPay').prop('disabled',false) if @totals > 0
    return

  toDay:( date ) ->
    if date.charAt(6) is '0' then date.substr(7,8) else date.substr(6,8)

  g:(roomId) -> @htmlSelect( roomId+'G', @Data.persons, 2, 'guests', @rooms[roomId].max )
  p:(roomId) -> @htmlSelect( roomId+'P', @Data.pets,    0, 'pets',   3                  )

  htmlSelect:( htmlId, array, choice, klass, max=undefined ) ->
    htm   = """<select name="#{htmlId}" id="#{htmlId}" class="#{klass}">"""
    where = if max? then (elem) -> elem <= max else () -> true
    for elem in array when where(elem)
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  onGuests:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @roomUIs[roomId].resRoom.guests = event.target.value
    #Util.log( 'Book.onGuests', roomId, @roomUIs[roomId].resRoom.guests, @calcPrice(roomId) )
    @updatePrice(roomId)
    return

  onPets:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @roomUIs[roomId].resRoom.pets = event.target.value
    #Util.log( 'Book.onPets', roomId, @roomUIs[roomId].resRoom.pets, @calcPrice(roomId) )
    @updatePrice(roomId)
    return

  onMonth:( event ) =>
    @month      = event.target.value
    @monthIdx   = @Data.months.indexOf(@month)
    @begDay     = if @month is 'May' then @begMay else 1
    $('#Days').val(@begDay.toString())
    #Util.log( 'Book.onMonth()', { monthIdx:@monthIdx, month:@month, begDay:@begDay } )
    @resetRooms()
    return

  onDay:( event ) =>
    @begDay = parseInt(event.target.value)
    if @month is 'October' and @begDay > 1
      @begDay = 1
      alert( 'The Season Ends on October 15' )
    else
      @resetRooms()
    return

  resetRooms:() ->
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml(@year,@monthIdx,@begDay,@numDays) )
    @roomsJQuery()

  onPop:() =>
    #Util.log( 'Book.onPop()'  )
    @getCust( true )
    @pay.testing = false
    return

  createRoomRes:() =>
    res = @res.createRoomRes( @totals, 'mine', @method, @roomUIs )
    #Util.log( 'Book.createRes()', res )
    for   own roomId, room of res.rooms
      for own dayId,  day  of room.days
        day.resId = res.resId
      onAdd = {}
      onAdd.days = room.days
      @store.add( 'Alloc', roomId, onAdd )
    res
    
  onCellBook:( event ) =>
    $cell  = $(event.target)
    [roomId,status] = @cellBook( $cell )
    @fillInRooms( roomId, $cell ) if status is 'mine'

  cellBook:( $cell ) ->
    status  = $cell.attr('data-status')
    roomId  = $cell.attr('id').substr(1,1)
    group   = @roomUIs[roomId].resRoom.group
    isEmpty = Util.isObjEmpty(group)
    if      status is 'free'
      status = 'mine'
      @updateCellStatus( $cell, 'mine' )
    else if status is 'mine' and     isEmpty
      status = 'free'
      @updateCellStatus( $cell, 'free' )
    else if status is 'mine' and not isEmpty
      status = 'free'
      @updateCellGroup( roomId, group, 'free' )
    [roomId,status]

  updateCellGroup:( roomId, group, status ) ->
    for own day,obj of group
      $cell = $('#R'+roomId+day)
      Util.log( 'Book.updateCellGroup()', { day:day,  group } )
      @updateCellStatus( $cell, status )
    return

  updateCellStatus:( $cell, status ) ->
    @cellStatus(     $cell, status )
    roomId = $cell.attr('id').substr(1,1)
    date   = $cell.attr('id').substr(2,8)
    roomUI = @roomUIs[roomId]
    if status is 'mine'
      roomUI.numDays++
      roomUI.resRoom.days[date] = { "status":status, "resId":"" }
      #Util.log( 'Book.updateCellStatus() mine', roomUI.numDays )
    else if status is 'free'
      roomUI.numDays-- if roomUI.numDays > 0
      delete roomUI.resRoom.days[ date]
      delete roomUI.resRoom.group[date] if roomUI.resRoom.group[date]?
      #Util.log( 'Book.updateCellStatus() free', roomUI.numDays )
    @updateTotal( roomId  )
    [roomId,status]

  # Only status of 'mine' is supported
  fillInRooms:( roomId, $last ) ->
    roomUI  = @roomUIs[roomId]
    days    = Object.keys(roomUI.resRoom.days).sort()
    bday    = days[0]
    weekday = @Data.weekday(days[0])
    weekend = weekday is 'Fri' or weekday is 'Sat'
    if      days.length is 1 and  weekend
      @fillInWeekend( roomId, bday )
    else if days.length is 2  and @fillIsConsistent( roomId, days, $last )
      @doFillInRooms( roomId, days )
    return

  fillInWeekend:( roomId, bday ) ->
    nday  = @Data.advanceDate( bday, 1 )
    if $('#R'+roomId+nday).attr('data-status') is 'free'
      group = @roomUIs[roomId].resRoom.group
      group[bday] = { status:'mine' }
      group[nday] = { status:'mine' }
      #Util.log( 'Book.fillInRooms()', { bday:bday, nday:nday, group })
      @updateCellStatus( $('#R'+roomId+nday), 'mine' )
    return

  fillIsConsistent:( roomId, days, $last ) ->
    bday = days[0]
    eday = days[days.length-1]
    nday = @Data.advanceDate( bday, 1 )
    while nday < eday                      # Avoid any booked rooms
      #Util.log( 'Book.fillInConsistent()', bday, nday, eday )
      $cell = $('#R'+roomId+nday)
      if not @Data.isElem($cell) or $cell.attr('data-status') isnt 'free'
        # Free up last clicked cell because an inconsistency was detected
        $last.attr('data-status','mine')
        @cellBook( $last )
        return false
      nday = @Data.advanceDate( nday, 1 )
    true

  doFillInRooms:( roomId, days ) ->
    bday = days[0]
    nday = @Data.advanceDate( bday, 1 )
    eday = days[days.length-1]
    while nday < eday
      #Util.log( 'Book.fillInRooms() Two', bday, nday, eday )
      $cell = $('#R'+roomId+nday)
      @cellBook( $cell ) if @Data.isElem( $('#R'+roomId+nday) )
      nday = @Data.advanceDate( nday, 1 )
    return

  onAlloc:( alloc, roomId ) =>
    for own day, obj of alloc.days
      @allocCell( day, obj.status, roomId )
    return

  allocCell:( day, status, roomId ) ->
    @cellStatus( $('#R'+roomId+day), status )

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)

  dayMonth:( day ) ->
    monthDay = day + @begDay - 1
    if monthDay > @Data.numDayMonth[@monthIdx] then monthDay-@Data.numDayMonth[@monthIdx] else monthDay

  toDateStr:( day ) ->
    @year+Util.pad(@monthIdx+1)+Util.pad(@dayMonth(day,@begDay))

  make:()   => @store.make(   'Room' )

  insert:() => @store.insert( 'Room', @rooms )



