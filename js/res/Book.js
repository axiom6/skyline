
$     = require( 'jquery'       )
Data  = require( 'js/res/Data'  )
Alloc = require( 'js/res/Alloc' )

class Book

  module.exports = Book

  constructor:( @stream, @store, @room, @cust, @res ) ->
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs
    @myDays      =  0
    @today       = new Date()
    @monthIdx    = @today.getMonth()
    @monthIdx    = 6
    @year        = 2017
    @month       = Data.months[@monthIdx]
    @begDay      =  9
    @weekdayIdx  = new Date( 2017, @monthIdx, 1 ).getDay()
    @numDays     = 14
    @$cells      = []
    @myCustId    = "12"
    Util.log('Book Constructor' )

  ready:() ->
    $('#Inits'   ).append( @initsHtml( ) )
    $('#Rooms'   ).append( @roomsHtml(@year,@monthIdx,@begDay,@numDays) )
    $('.guests'  ).change( @onGuests  )
    $('.pets'    ).change( @onPets    )
    $('#Months'  ).change( @onMonth   )
    $('#Days'    ).change( @onDay     )
    $('#Test'    ).click(  @onTest    )
    $('#Pay'     ).click(  @onPay     )
    $('#Approve' ).click(  @onApprove )
    @roomsJQuery()

  initsHtml:() ->
    htm     = """<label class="init-font">&nbsp;&nbsp;Arrive:#{ @htmlSelect( "Months", Data.months, @month,  'months' ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;       #{ @htmlSelect( "Days",   Data.days,   @begDay, 'days'   ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;#{@year}</label>"""
    htm    += """<span  class="init-font" id="Test">&nbsp;&nbsp;Test</span>"""
    htm

  roomsHtml:( year, monthIdx, begDay, numDays ) ->
    weekdayIdx  = new Date( year, monthIdx, 1 ).getDay()
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th></th><th></th><th></th>"""
    for day in [1..numDays]
      weekday = Data.weekdays[(weekdayIdx+day-1)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Price</th>"
    for day in [1..numDays]
      htm += "<th>#{@dayMonth(day,begDay)}</th>"
    htm += "<th>Total</th></tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td>#{room.name}</td><td class="guests">#{@g(roomId)}</td><td class="pets">#{@p(roomId)}</td><td id="#{roomId}M" class="room-price">#{'$'+@calcPrice(roomId)}</td>"""
      for day in [1..numDays]
        htm += @createCell( roomId, room, @toDateStr(day) )
      htm += """<td class="room-total" id="#{roomId}T"></td></tr>"""
    htm += """<tr>"""
    htm += """<td></td>""" for day in [1..@numDays+4]
    htm += """<td class="room-total" id="Totals">&nbsp;</td></tr>"""
    htm += "</tbody></table>"
    htm

  createCell:( roomId, room, date ) ->
    status = @room.dayBooked( room, date )
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
    return

  calcPrice:( roomId ) =>
    roomUI = @roomUIs[roomId]
    guests = roomUI.guests
    pets   = roomUI.pets
    price  = @rooms[roomId][guests]+pets*Data.petPrice
    roomUI.price = price
    price

  updatePrice:(   roomId ) =>
    $('#'+roomId+'M').text("#{'$'+ @calcPrice(roomId) }")
    @updateTotal( roomId )
    return

  updateTotal:( roomId ) ->
    price = @calcPrice( roomId )
    room  = @roomUIs[roomId]
    room.total = price * room.numDays
    text = if room.total is 0 then '' else '$'+room.total
    $('#'+roomId+'T').text(text)
    @updateTotals()
    return

  newCust:() ->
    { status:'mine', days:[], total:0 }

  updateTotals:() ->
    totals = 0
    for own roomId, room of @roomUIs
      totals += room.total
    text = if totals is 0 then '' else '$'+totals
    $('#Totals').text(text)
    return

  toDay:( date ) ->
    if date.charAt(6) is '0' then date.substr(7,8) else date.substr(6,8)

  g:(roomId) -> @htmlSelect( roomId+'G', Data.persons, 2, 'guests', @rooms[roomId].max )
  p:(roomId) -> @htmlSelect( roomId+'P', Data.pets,    0, 'pets',   3                  )

  htmlSelect:( htmlId, array, choice, klass, max=undefined ) ->
    htm  = """<select id="#{htmlId}" class="#{klass}">"""
    where = if max? then (elem) -> elem <=max else () -> true
    for elem in array when where(elem)
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  onGuests:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @roomUIs[roomId].guests = event.target.value
    Util.log( 'Book.onGuests', roomId, @roomUIs[roomId].guests, @calcPrice(roomId) )
    @updatePrice(roomId)
    return

  onPets:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @roomUIs[roomId].pets = event.target.value
    Util.log( 'Book.onPets', roomId, @roomUIs[roomId].pets, @calcPrice(roomId) )
    @updatePrice(roomId)
    return

  onMonth:( event ) =>
    @month      = event.target.value
    @monthIdx   = Data.months.indexOf(@month)
    @weekdayIdx = new Date( @year, @monthIdx, 1 ).getDay()
    @resetRooms()
    return

  onDay:( event ) =>
    @begDay = parseInt(event.target.value)
    @resetRooms()
    return

  resetRooms:() ->
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml(@year,@monthIdx,@begDay,@numDays) )
    @roomsJQuery()

  onTest:() =>
    Util.log( 'Book.onTest()' )
    @store.insert( 'Alloc', Alloc.Allocs )

  onPay:() =>
    Util.log( 'Book.onTest()' )
    for own roomId, room of @roomUIs

  onCellBook:( event ) =>
    $cell  = $(event.target)
    status = $cell.attr('data-status')
    if      status is 'free'
            status =  'mine'
    else if status is 'mine'
            status =  'free'
    @cellStatus( $cell, status )
    roomId = $cell.attr('id').substr(1,1)
    date   = $cell.attr('id').substr(2,8)
    @roomUIs[roomId].numDays += if status is 'mine' then 1 else -1
    @roomUIs[roomId].numDays  = 0 if @roomUIs[roomId].numDays < 0
    date = @roomUIs[roomId].days[date]
    date = if date? then date else
    Util.log('Book.onCellBook()', roomId, date )
    @updateTotal( roomId, date, status )

  onAlloc:( alloc, roomId ) =>
    #Util.log( 'Book.onAlloc()' )
    for own day, obj of alloc.days
      @allocCell( day, obj.status, roomId )
    return

  allocCell:( day, status, roomId ) ->
    @cellStatus( $('#R'+roomId+day), status )

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)

  dayMonth:( iday, begDay ) ->
    day = begDay + iday - 1
    if day > Data.numDayMonth[@monthIdx] then day-Data.numDayMonth[@monthIdx] else day

  toDateStr:( day ) ->
    @year+Util.pad(@monthIdx+1)+Util.pad(@dayMonth(day,@begDay))

  make:()   => @store.make(   'Room' )

  insert:() => @store.insert( 'Room', @rooms )
