
$ = require( 'jquery' )

class Book

  module.exports = Book

  constructor:( @stream, @store, @Data, @res, @pay, @pict ) ->
    @rooms    = @res.rooms
    @roomUIs  = @res.createRoomUIs( @rooms )
    @res.book = @
    @$cells   = []
    @totals   = 0
    @method   = 'site'

  ready:() ->
    $('#Book'    ).empty()
    $('#Pays'    ).empty()
    $('#Book'    ).append( @bookHtml()  )
    $('#Insts'   ).append( @instructHtml() )
    $('#Inits'   ).append( @initsHtml() )
    $('#Rooms'   ).append( @roomsHtml(@res.year,@res.monthIdx,@res.begDay,@res.numDays) )
    $('#Guest'   ).append( @guestHtml() )
    $('.guests'  ).change( @onGuests  )
    $('.pets'    ).change( @onPets    )
    $('.SpaCheck').change( @onSpa     )
    $('#Months'  ).change( @onMonth   )
    $('#Days'    ).change( @onDay     )
    $('#Pop'     ).click(  @onPop     )
    $('#Test'    ).click(  @onTest     )
    $('#GoToPay' ).click(  @onGoToPay ) # .prop('disabled',true)
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
    htm  = """<label for="Months" class="InitIp">Start: #{ @htmlSelect( "Months", @Data.season, @res.month,  'months' ) }</label>"""
    htm += """<label for="Days"   class="InitIp">       #{ @htmlSelect( "Days",   @Data.days,   @res.begDay, 'days'   ) }</label>"""
    htm += """<label class="InitIp">&nbsp;&nbsp;#{2000+@res.year}</label>"""
    htm += """<span  id="Pop"  class="Test">Pop</span>"""
    htm += """<span  id="Test" class="Test">Test</span>"""
    htm

  seeRoom:( roomId, room ) ->
    #"""<a href="rooms/#{roomId}.html" id="#{roomId}L">#{room.name}</a>"""
    room.name

  roomsHtml:( year, monthIdx, begDay, numDays ) ->
    weekdayIdx  = new Date( 2000+year, monthIdx, 1 ).getDay()
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th></th><th></th><th></th><th></th>"""
    for day in [1..numDays]
      weekday = @Data.weekdays[(weekdayIdx+begDay+day-2)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th>"
    for day in [1..numDays]
      htm += "<th>#{@res.dayMonth(day)}</th>"
    htm += "<th>Total</th></tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td class="td-left">#{@seeRoom(roomId,room)}</td><td class="guests">#{@g(roomId)}</td><td class="pets">#{@p(roomId)}</td><td>#{@spa(roomId)}</td><td id="#{roomId}M" class="room-price">#{'$'+@calcPrice(roomId)}</td>"""
      for day in [1..numDays]
        htm += @createCell( roomId, room, @res.toDateStr(day) )
      htm += """<td class="room-total" id="#{roomId}T"></td></tr>"""
    htm += """<tr>"""
    htm += """<td></td>""" for day in [1..numDays+5]
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

  getCust:( testing=false ) ->
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
      @pay.initPay( @totals, cust, @roomUIs )
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
    status = @res.dayBooked( roomId, date )
    """<td id="R#{roomId+date}" class="room-#{status}" data-status="#{status}"></td>"""

  roomsJQuery:() ->
    for $cell in @$cells
        $cell.unbind( "click" )
    @$cells = []
    for roomId, roomUI of @roomUIs
      roomUI.$ = $('#'+roomId) # Keep jQuery out of room database table
      for day in [1..@res.numDays]
        date  = @res.toDateStr(day)
        $cell = $('#R'+roomId+date)
        $cell.click( (event) => @onCellBook(event) )
        @$cells.push( $cell )
        @updateTotal( roomId )
    return

  calcPrice:( roomId ) =>
    roomUI = @roomUIs[roomId]
    guests = roomUI.guests
    pets   = roomUI.pets
    price  = @rooms[roomId][guests]+pets*@Data.petPrice
    roomUI.price = price
    price

  updatePrice:(   roomId ) =>
    $('#'+roomId+'M').text("#{'$'+ @calcPrice(roomId) }")
    @updateTotal( roomId )
    return

  updateTotal:( roomId ) ->
    price  = @calcPrice( roomId )
    room   = @roomUIs[roomId]
    nights = Util.keys(room.days).length
    room.total = price * nights + room.change
    # Util.log( 'Book.updateTotal()', { roomId:roomId, nights:nights, change:room.change, total:room.total } )
    text = if room.total is 0 then '' else '$'+room.total
    $('#'+roomId+'T').text(text)
    @updateTotals()
    return

  updateTotals:() ->
    @totals = 0
    for own roomId, room of @roomUIs
      @totals += room.total
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
    @roomUIs[roomId].guests = event.target.value
    #Util.log( 'Book.onGuests', roomId, @roomUIs[roomId].guests, @calcPrice(roomId) )
    @updatePrice(roomId)
    return

  onPets:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @roomUIs[roomId].pets = event.target.value
    #Util.log( 'Book.onPets', roomId, @roomUIs[roomId].pets, @calcPrice(roomId) )
    @updatePrice(roomId)
    return

  spa:( roomId ) ->
    if @res.optSpa(roomId) then """<input id="#{roomId}SpaCheck" class="SpaCheck" type="checkbox" value="#{roomId}" checked>""" else ""

  onSpa:( event ) =>
    $elem   = $(event.target)
    roomId  = $elem.attr('id').charAt(0)
    roomUI  = @roomUIs[roomId]
    checked = $elem.is(':checked')
    spaFee  = if checked then  20         else -20
    reason  = if checked then 'Spa Added' else 'Spa Opted Out'
    roomUI.change += spaFee
    roomUI.reason  = reason
    @updateTotal( roomId )  if roomUI.total > 0
    #Util.log('Book.onSpa()', { room:roomId, change:roomUI.change, reason:readon, total:roomUI.total, totals:@totals } )
    return

  onMonth:( event ) =>
    @res.month      = event.target.value
    @res.monthIdx   = @Data.months.indexOf(@month)
    @res.begDay     = if @month is 'May' then @begMay else 1
    $('#Days').val(@res.begDay.toString())
    @res.dateRange( @resetRooms )
    @resetRooms()
    return

  onDay:( event ) =>
    @res.begDay = parseInt(event.target.value)
    if @res.month is 'October' and @res.begDay > 1
      @res.begDay = 1
      alert( 'The Season Ends on October 15' )
    @res.dateRange( @resetRooms )
    @resetRooms()
    return

  resetRooms:() =>
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml( @res.year, @res.monthIdx, @res.begDay, @res.numDays ) )
    @roomsJQuery()

  onPop:() =>
    #Util.log( 'Book.onPop()'  )
    @getCust( true )
    @pay.testing = true
    return

  onTest:() =>
    @test.doTest() if @test?
    return
    
  onCellBook:( event ) =>
    $cell  = $(event.target)
    [roomId,status] = @cellBook( $cell )
    @fillInRooms( roomId, $cell ) if status is 'mine'

  cellBook:( $cell ) ->
    status  = $cell.attr('data-status')
    roomId  = $cell.attr('id').substr(1,1)
    group   = @roomUIs[roomId].group
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
      roomUI.days[date] = { "status":status, "resId":"" }
    else if status is 'free'
      delete roomUI.days[ date]
      delete roomUI.group[date] if roomUI.group[date]?
    @updateTotal( roomId  )
    [roomId,status]

  # Only status of 'mine' is supported
  fillInRooms:( roomId, $last ) ->
    roomUI  = @roomUIs[roomId]
    days    = Util.keys(roomUI.days).sort()
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
      group = @roomUIs[roomId].group
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

  onAlloc:( roomId, days ) =>
    for own dayId, day of days
      @allocCell( dayId, day.status, roomId )
    return

  allocCell:( dayId, status, roomId ) ->
    @cellStatus( $('#R'+roomId+dayId), status )

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)







