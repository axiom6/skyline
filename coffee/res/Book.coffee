
$    = require( 'jquery'     )
Data = require( 'js/res/Data')

class Book

  module.exports = Book
  Book.Allocs    = require( 'data/Alloc.json' )
  Book.States    = ["book","depo","hold","free"]

  constructor:( @stream, @store, @room, @cust ) ->
    @subscribe()
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs
    @initRooms()

    @guests      = "2"
    @pet         =  0
    @myDays      =  0
    @petPrice    = 12
    @today       = new Date()
    @monthIdx    = @today.getMonth()
    @monthIdx    = 2 # 2 is July if 4 < @monthIdx and @monthIdx < 10 then @monthIdx else 0
    @year        = "2017"
    @month       = Data.months[@monthIdx] # if 4 < @monthIdx and @monthIdx < 10 then @months[@monthIdx] else "May"
    @begDay      =  9
    @weekdayIdx  = new Date( 2017, @monthIdx, 1 ).getDay()
    @numDays     = 14
    @$cells      = []
    @myCustId    = "12"
    Util.log('Book Constructor' )

  ready:() ->
    $('#Inits').append( @initsHtml( ) )
    $('#Rooms').append( @roomsHtml( ) )
    $('#Guests').change( @onGuests )
    $('#Pets'  ).change( @onPets   )
    $('#Months').change( @onMonth  )
    $('#Days'  ).change( @onDay    )
    $('#Test'  ).click(  @onTest   )
    @initAlloc()
    @roomsJQuery()

  subscribe:() ->
    @stream.subscribe( 'Alloc', (alloc) => @onAlloc( alloc ) )
    return

  initsHtml:() ->
    htm     = """<label class="init-font">&nbsp;&nbsp;Guests:#{ @htmlSelect( "Guests", Data.persons, @guests ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;Pets:  #{ @htmlSelect( "Pets",   Data.pets,    @pet    ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;Arrive:#{ @htmlSelect( "Months", Data.months,  @month  ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;       #{ @htmlSelect( "Days",   Data.days,    @begDay ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;#{@year}</label>"""
    htm    += """<span  class="init-font" id="Test">&nbsp;&nbsp;Test</span>"""
    htm

  roomsHtml:( ) ->
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th id="NumGuests">#{@guests}&nbsp;Guests</th>"""
    for day in [1..@numDays]
      weekday = Data.weekdays[(@weekdayIdx+day-1)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th>Room</th></tr><tr><th>Cottage</th><th>#{@pet}&nbsp;Pets</th>"
    for day in [1..@numDays]
      htm += "<th>#{@dayMonth(day)}</th>"
    htm += "<th>Total</th></tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td>#{room.name}</td><td id="#{roomId}Price" class="room-price">#{'$'+@calcPrice(room)}</td>"""
      for day in [1..@numDays]
        date = @toDateStr(day)
        htm += @createCell( room, date )
      htm += """<td class="room-total" id="#{roomId}Total"></td></tr>"""
    htm += """<tr><td></td><td></td>"""
    htm += """<td></td>""" for day in [1..@numDays]
    htm += """<td class="room-total" id="Totals">&nbsp;</td></tr>"""
    htm += "</tbody></table>"
    htm

  roomsJQuery:() ->
    for $cell in @$cells
        $cell.unbind( "click" )
    @$cells = []
    for roomId, roomUI of @roomUIs
      roomUI.$ = $('#'+roomId) # Keep jQuery out of room database table
      for day in [1..@numDays]
        date  = @toDateStr(day)
        $cell = $('#'+roomId+date)
        $cell.click( (event) => @onCellBook(event) )
        @$cells.push( $cell )
    return

  createCell:( room, date ) ->
    status = @dayBooked( room, date )
    """<td id="#{room.roomId+date}" class="room-#{status}" data-status="#{status}"></td>"""

  calcPrice:( room ) ->
    price = room[@guests]+@pet*@petPrice
    room.price = price
    price

  updatePrice:( room ) ->
    roomId = room.roomId
    if @guests > room.max
      @roomUIs[roomId].$.hide()
    else
      @roomUIs[roomId].$.show()
      $('#P'+roomId).text("#{'$'+ @calcPrice(room) }")
    return

  updatePrices:() ->
    for own roomId, room of @rooms
      @updatePrice( room )

  updateTotal:( room, date, status ) ->
    price = room.price
    room.total += if status is 'mine' then price else -price
    text = if room.total is 0 then '' else '$'+room.total
    $('#'+room.roomId+'Total').text(text)
    @updateTotals()
    return

  newCust:() ->
    { status:'mine', days:[], total:0 }

  updateTotals:() ->
    totals = 0
    for own roomId, room of @rooms
      totals += room.total
    text = if totals is 0 then '' else '$'+totals
    $('#Totals').text(text)
    return

  toDay:( date ) ->
    if date.charAt(6) is '0' then date.substr(7,8) else date.substr(6,8)

  dayBooked:( room, date ) ->
    for status in Book.States when room[status]?
      for day  in room[status]
        return status if day is date
    'free'

  htmlSelect:( htmlId, array, choice  ) ->
    htm  = """<select id="#{htmlId}">"""
    for elem in array
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  onGuests:( event ) =>
    @guests = event.target.value
    $('#NumGuests').text(@guests)
    @updatePrices()
    return

  onMonth:( event ) =>
    @month      = event.target.value
    @monthIdx   = @months.indexOf(@month)
    @weekdayIdx = new Date( 2017, @monthIdx, 1 ).getDay()
    @resetRooms()
    return

  onDay:( event ) =>
    @begDay = parseInt(event.target.value)
    @resetRooms()
    return

  resetRooms:() ->
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml( ) )
    @roomsJQuery()

  onPets:( event ) =>
    @pet = event.target.value
    @updatePrices()
    return

  initRooms:() =>
    @store.subscribe( 'Room', 'none', 'make',  (make)  => @store.insert( 'Room', @rooms )  )
    @store.make( 'Room' )

  initAlloc:() ->
    @store.subscribe( 'Alloc', 'none', 'onAdd', (onAdd)  => Util.log( 'Alloc.onAdd()', onAdd ); @onAlloc(onAdd) )
    @store.subscribe( 'Alloc', 'none', 'onPut', (onPut)  => Util.log( 'Alloc.onPut()', onPut ) )
    @store.subscribe( 'Alloc', 'none', 'onDel', (onDel)  => Util.log( 'Alloc.onDel()', onDel ) )
    @store.make(      'Alloc' )
    @store.on( 'Alloc', 'onAdd' )
    @store.on( 'Alloc', 'onPut' )
    @store.on( 'Alloc', 'onDel' )

  onTest:() =>
    Util.log( 'Book.onTest()' )
    @store.insert( 'Alloc', Book.Allocs )

  onCellBook:( event ) =>
    $cell  = $(event.target)
    status = $cell.attr('data-status')
    if      status is 'free'
            status =  'mine'
    else if status is 'mine'
            status =  'free'
    @cellStatus( $cell, status )
    roomId = $cell.attr('id').substr(0,1)
    date   = $cell.attr('id').substr(1,8)
    @updateTotal( roomId, date, status )

  onAlloc:( onAdd ) =>
    Util.log( 'Book.onAlloc()', { onEvt:onAdd.onEvt, table:onAdd.table, key:onAdd.key, val:onAdd.val } )
    alloc = onAdd.val
    for status in Book.States when alloc[status]?
      for day  in alloc[status]
        @allocRoom( alloc, day, status )
        @allocCell( alloc, day, status )
    #@store.put( 'Room', alloc.roomId )
    return

  allocRoom:( alloc, day, status ) ->
    room         = @rooms[alloc.roomId]
    room[status] = if room[status]? then room[status] else []
    roomDays     = room[status]
    roomDays.push(day) if not Util.inArray(roomDays,day)

  allocCell:( alloc, day, status ) ->
    @cellStatus( $('#'+alloc.roomId+day), status )

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)

  dayMonth:( iday ) ->
    day = @begDay + iday - 1
    if day > Data.numDayMonth[@monthIdx] then day-Data.numDayMonth[@monthIdx] else day

  toDateStr:( day ) ->
    @year+Util.pad(@monthIdx+5)+Util.pad(@dayMonth(day))

  make:()   => @store.make(   'Room' )

  insert:() => @store.insert( 'Room', @rooms )
