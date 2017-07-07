
$    = require( 'jquery' )
Data = require( 'js/res/Data'   )
UI   = require( 'js/res/UI'     )

class Book

  module.exports = Book

  constructor:( @stream, @store, @res, @pay, @pict ) ->
    @rooms    = @res.rooms
    @res.book = @
    @$cells   = []
    @totals   = 0
    @method   = 'site'

  ready:() ->
    @res.roomUI( @rooms )
    $('#Book'    ).empty()
    $('#Pays'    ).empty()
    $('#Book'    ).append( @bookHtml()  )
    $('#Insts'   ).append( @instructHtml() )
    $('#Inits'   ).append( @initsHtml() )
    $('#Rooms'   ).append( @roomsHtml(Data.year,Data.monthIdx,Data.begDay,Data.numDays) )
    $('#Guest'   ).append( @guestHtml() )
    $('.guests'  ).change( @onGuests  )
    $('.pets'    ).change( @onPets    )
    $('.SpaCheck').change( @onSpa     )
    $('#Months'  ).change( @onMonth   )
    $('#Days'    ).change( @onDay     )
    $('#Pop'     ).click(  @onPop     )
    $('#Test'    ).click(  @onTest     )
    $('#GoToPay' ).click(  @onGoToPay ) # .prop('disabled',true)
    $('#Totals').css( { height:'21px' } )
    $('#Navb').hide()
    $('#Book').show()
    @roomsJQuery()

  bookHtml:() ->
    """
    <div id="Make" class="Title">Make Your Reservation</div>
    <div id="Insts"></div>
    <div><div id="Inits"></div></div>
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
    htm  = """<label for="Months" class="InitIp">Start: #{ UI.htmlSelect( "Months", Data.season, Data.month  ) }</label>"""
    htm += """<label for="Days"   class="InitIp">       #{ UI.htmlSelect( "Days",   Data.days,   Data.begDay ) }</label>"""
    htm += """<label class="InitIp">&nbsp;&nbsp;#{2000+Data.year}</label>"""
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
      weekday = Data.weekdays[(weekdayIdx+begDay+day-2)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th>"
    for day in [1..numDays]
      htm += "<th>#{Data.dayMonth(day)}</th>"
    htm += "<th>Total</th></tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td class="td-left">#{@seeRoom(roomId,room)}</td><td class="guests">#{@g(roomId)}</td><td class="pets">#{@p(roomId)}</td><td>#{@spa(roomId)}</td><td id="#{roomId}M" class="room-price">#{'$'+@calcPrice(roomId)}</td>"""
      for day in [1..numDays]
        htm += @createCell( roomId, room, day )
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

  createCust:( testing=false ) ->
    [first,fv] = @isValid('First', 'Samuel',      testing )
    [last, lv] = @isValid('Last',  'Hosendecker', testing )
    [phone,pv] = @isValid('Phone', '3037977129',  testing )
    [email,ev] = @isValid('EMail', 'Thomas.Edmund.Flaherty@gmail.com', testing )
    tv   = @totals > 0
    cust = @res.createCust( first, last, phone, email, "site" )
    [tv,fv,lv,pv,ev,cust]

  # Significant transition from Book to Pay
  onGoToPay:( e ) =>
    e.preventDefault() if e?
    [tv,fv,lv,pv,ev,cust] = @createCust()
    if tv and fv and lv and pv and ev
      $('.NameER').hide()
      $('#Book').hide()
      @pay.initPayResv( @totals, cust, @rooms )
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

  createCell:( roomId, roomRm, day ) ->
    date   = Data.toDateStr( Data.dayMonth(day) )
    status = @getStatus( roomId, date )
    """<td id="#{@cellId(date,roomId)}" class="room-#{status}" data-status="#{status}"></td>"""

  getStatus:( roomId, date ) ->
    room = @rooms[roomId]
    if not Util.isObjEmpty(room.days) and room.days[date].status?
      room.days[date].status
    else
      @res.getStatus( roomId, date )

  cellId:( date,  roomId ) ->
     'R' + date + roomId

  resId:( date,  roomId ) ->
          date + roomId

  roomIdCell:( $cell ) ->
    $cell.attr('id').substr(7,1)

  dateCell:( $cell ) ->
    $cell.attr('id').substr(1,6)

  $cell:( date,  roomId ) ->
    $( '#' + @cellId(date,roomId) )

  roomsJQuery:() ->
    $cell.unbind( "click" ) for $cell in @$cells
    @$cells = []
    for roomId, room of @rooms
      room.$ = $('#'+roomId) # Keep jQuery out of room database table
      for day in [1..Data.numDays]
        date  = Data.toDateStr( Data.dayMonth(day) )
        $cell = @$cell(date,roomId)
        $cell.click( (event) => @onCellBook(event) )
        @$cells.push( $cell )
        @updateTotal( roomId )
    return

  calcPrice:( roomId ) =>
    room   = @rooms[roomId]
    guests = room.guests
    pets   = room.pets
    price  = @rooms[roomId][guests]+pets*Data.petPrice
    room.price = price
    price

  updateTotal:( roomId ) ->
    price  = @calcPrice( roomId )
    $('#'+roomId+'M').text("#{'$'+ price }")
    room   = @rooms[roomId]
    nights = Util.keys(room.days).length
    room.total = price * nights + room.change
    # Util.log( 'Book.updateTotal()', { roomId:roomId, nights:nights, change:room.change, total:room.total } )
    text = if room.total is 0 then '' else '$'+room.total
    $('#'+roomId+'T').text(text)
    @updateTotals()
    return

  updateTotals:() ->
    @totals = 0
    for own roomId, room of @rooms
      @totals += room.total
    text = if @totals is 0 then '' else '$'+@totals
    $('#Totals').text(text)
    $('#GoToPay').prop('disabled',false) if @totals > 0
    return

  g:(roomId) -> @res.htmlSelect( roomId+'G', Data.persons, 2, 'guests', @rooms[roomId].max )
  p:(roomId) -> @res.htmlSelect( roomId+'P', Data.pets,    0, 'pets',   3                  )

  onGuests:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @rooms[roomId].guests = event.target.value
    @updateTotal(roomId)
    return

  onPets:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @rooms[roomId].pets = event.target.value
    @updateTotal(roomId)
    return

  spa:( roomId ) ->
    if @res.optSpa(roomId) then """<input id="#{roomId}SpaCheck" class="SpaCheck" type="checkbox" value="#{roomId}" checked>""" else ""

  onSpa:( event ) =>
    $elem   = $(event.target)
    roomId  = $elem.attr('id').charAt(0)
    room    = @rooms[roomId]
    checked = $elem.is(':checked')
    spaFee  = if checked then  20         else -20
    reason  = if checked then 'Spa Added' else 'Spa Opted Out'
    room.change += spaFee
    room.reason  = reason
    @updateTotal( roomId )  if room.total > 0
    return

  onMonth:( event ) =>
    Data.month     = event.target.value
    Data.monthIdx  = Data.months.indexOf(Data.month)
    Data.begDay    = if Data.month is 'May' then Data.begMay else 1
    $('#Days').val(Data.begDay.toString())
    @resetRooms() # or resetDateRange:()
    return

  onDay:( event ) =>
    Data.begDay = parseInt(event.target.value)
    if Data.month is 'October' and Data.begDay > 1
      Data.begDay = 1
      alert( 'The Season Ends on October 15' )
    @resetRooms() # or resetDateRange:()
    return

  # Not needed because we have the whole date range for the season
  resetDateRange:() ->
    beg = Data.toDateStr( Data.begDay, Data.monthIdx )
    end = Data.advanceDate( beg, Data.numDays-1 )
    @res.dateRange( beg, end, @resetRooms )

  resetRooms:() =>
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml( Data.year, Data.monthIdx, Data.begDay, Data.numDays ) )
    @roomsJQuery()

  onPop:() =>
    #Util.log( 'Book.onPop()'  )
    @createCust( true )
    @pay.testing = true
    return

  onTest:() =>
    @test.doTest() if @test?
    return
    
  onCellBook:( event ) =>
    $cell  = $(event.target)
    [roomId,status] = @cellBook( $cell )
    @fillInRooms( roomId, $cell ) if status is 'Mine'

  cellBook:( $cell ) ->
    status = $cell.attr('data-status')
    date   = @dateCell(   $cell )
    roomId = @roomIdCell( $cell )
    resId  = @resId( date, roomId )
    if      status is 'Free'
      status = 'Mine'
      @updateCellStatus( $cell, 'Mine', resId )
    else if status is 'Mine'
      status = 'Free'
      @updateCellStatus( $cell, 'Free', resId )
    [roomId,status]

  updateCellStatus:( $cell, status, resId ) ->
    @cellStatus(     $cell, status )
    date   = @dateCell(   $cell )
    roomId = @roomIdCell( $cell )
    room   = @rooms[roomId]
    resId  = @resId( date, roomId )
    if status is 'Mine'
      room.days[date]  = { "status":status, "resId":resId }
    else if status is 'Free'
      delete  room.days[date]
      weekday = Data.weekday(date)
      if weekday is 'Fri' or weekday is 'Sat'
        nday = Data.advanceDate( date, 1 )
        @cellStatus( @$cell( nday, roomId ), 'Free' )
        delete room.days[nday]
    @updateTotal( roomId  )
    [roomId,status]

  # Only status of 'Mine' is supported
  fillInRooms:( roomId, $end ) ->
    days    = @dayArray( roomId  )
    return if days is 'none'
    bday    = days[0]
    weekday = Data.weekday(bday)
    weekend = weekday is 'Fri' or weekday is 'Sat'
    if      days.length is 1 and  weekend
      @fillInNextDay( bday, roomId )
    else if days.length is 2 and @fillIsConsistent( roomId, days, $end )
      @doFillInRooms( days, roomId )
    return

  dayArray:( roomId ) ->
    days  = []
    for date, day of @rooms[roomId].days
        days.push( date )
    if Util.isArray(days) then days.sort() else 'none'

  fillInNextDay:(   bday, roomId ) ->
    resId = @resId( bday, roomId )
    nday  = Data.advanceDate( bday, 1 )
    $cell = @$cell(nday,roomId)
    if $cell.attr('data-status') is 'Free'
      @updateCellStatus( $cell, 'Mine', resId )
    return

  fillIsConsistent:( roomId, days, $end ) ->
    bday = days[0]
    eday = days[days.length-1]
    nday = Data.advanceDate( bday, 1 )
    while nday < eday                      # Avoid any booked rooms
      $cell = @$cell(nday,roomId)
      if not Data.isElem($cell) or $cell.attr('data-status') isnt 'Free'
        # Free up last clicked cell because an inconsistency was detected
        $end.attr('data-status','Mine')
        @cellBook( $end )
        return false
      nday = Data.advanceDate( nday, 1 )
    true

  doFillInRooms:( days, roomId ) ->
    bday = days[0]
    nday = Data.advanceDate( bday, 1 )
    eday = days[days.length-1]
    while nday < eday
      #Util.log( 'Book.fillInRooms() Two', bday, nday, eday )
      $cell = @$cell(nday,roomId)
      @cellBook( $cell ) if Data.isElem( $cell )
      nday = Data.advanceDate( nday, 1 )
    return

  allocDays:( days ) =>
    for own dayId, day of days
      date   = Data.toDate( dayId )
      roomId = Data.roomId( dayId )
      @allocCell( date, day.status, roomId )
    return

  allocResv:( resv ) ->
    #$cell = @$cell( resv.arrive, resv.roomId )
    #$div  = $cell.find('div')
    #$div.text( resv.last )
    return

  allocCell:( date, status, roomId ) ->
    @cellStatus( @$cell(date,roomId), status )

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)
