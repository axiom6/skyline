
$ = require( 'jquery' )

class Book

  module.exports    = Book
  Book.Room         = require( 'data/Room.json'  )
  Book.Book         = require( 'data/Book.json'  )
  Book.Alloc        = require( 'data/Alloc.json' )

  constructor:( @stream, @store, @room, @cust ) ->
    @numDayMonth = [            31,30,31,31,30,31]
    @allDayMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    @months      = [                                     "May","June","July","August","September","October"]
    @monthsAll   = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    @weekdays    = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    @days        = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
    @persons     = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    @pets        = ["0","1","2","3"]
    @guests      = "2"
    @pet         =  0
    @myDays      =  0
    @petPrice    = 12
    @today       = new Date()
    @monthIdx    = @today.getMonth()
    @monthIdx    = 2 # 2 is July if 4 < @monthIdx and @monthIdx < 10 then @monthIdx else 0
    @year        = "2017"
    @month       = @months[@monthIdx] # if 4 < @monthIdx and @monthIdx < 10 then @months[@monthIdx] else "May"
    @begDay      =  9
    @weekdayIdx  = new Date( 2017, @monthIdx, 1 ).getDay()
    @numDays     = 14
    @$cells      = []
    Util.log('Book Constructor' )

  ready:() ->
    $('#Inits').append( @initsHtml( ) )
    $('#Rooms').append( @roomsHtml( ) )
    $('#Guests').change( @onGuests )
    $('#Pets'  ).change( @onPets   )
    $('#Months').change( @onMonth  )
    $('#Days'  ).change( @onDay    )
    $('#Test'  ).click(  @onTest   )
    @roomsJQuery()
    @subscribe()

  subscribe:() ->
    @stream.subscribe( 'Alloc', (alloc) => @onAlloc( alloc ) )
    return

  initsHtml:() ->
    htm     = """<label class="init-font">&nbsp;&nbsp;Guests:#{ @htmlSelect( "Guests", @persons, @guests ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;Pets:  #{ @htmlSelect( "Pets",   @pets,    @pet    ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;Arrive:#{ @htmlSelect( "Months", @months,  @month  ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;       #{ @htmlSelect( "Days",   @days,    @begDay ) }</label>"""
    htm    += """<label class="init-font">&nbsp;&nbsp;#{@year}</label>"""
    htm    += """<span  class="init-font" id="Test">&nbsp;&nbsp;Test</span>"""
    htm

  roomsHtml:( ) ->
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th id="NumGuests">#{@guests}&nbsp;Guests</th>"""
    for day in [1..@numDays]
      weekday = @weekdays[(@weekdayIdx+day-1)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th></th></tr><tr><th>Cottage</th><th>#{@pet}&nbsp;Pets</th>"
    for day in [1..@numDays]
      htm += "<th>#{@dayMonth(day)}</th>"
    htm += "<th></th></tr></thead><tbody>"
    for own roomId, room of Book.Room
      htm += """<tr id="#{roomId}"><td>#{room.name}</td><td id="P#{roomId}" class="room-price">#{'$'+@calcPrice(room)}</td>"""
      for day in [1..@numDays]
        date = @toDateStr(day)
        htm += @createCell( roomId, Book.Book[roomId], date )
      htm += """<td class="btn-book">Book</td></tr>"""
    htm += "</tbody></table>"
    htm

  roomsJQuery:() ->
    for $cell in @$cells
        $cell.unbind( "click" )
    @$cells = []
    for roomId, room of Book.Room
      room.$ = $('#'+roomId)
      for day in [1..@numDays]
        date  = @toDateStr(day)
        $cell = $('#'+roomId+date)
        $cell.click( (event) => @onCell(event) )
        @$cells.push( $cell )
    return

  createCell:( roomId, book, date ) ->
    status = @dayBooked( book, date )
    """<td id="#{roomId+date}" class="room-#{status}"></td>"""

  calcPrice:( room ) ->
    room[@guests]+@pet*@petPrice

  updatePrice:( roomId, room ) ->
    if @guests > room.max
      room.$.hide()
    else
      room.$.show()
      $('#P'+roomId).text("#{'$'+ @calcPrice(room) }")
    return

  updatePrices:() ->
    for own roomId, room of Book.Room
      @updatePrice( roomId, room )

  toDay:( date ) ->
    if date.charAt(6) is '0' then date.substr(7,8) else date.substr(6,8)

  dayBooked:( book, date ) ->
    for own custId, cust of book
      for day in cust.days
        return cust.status if day is date
    'free'

  htmlSelect:( htmlId, array, choice  ) ->
    htm  = """<select id="#{htmlId}">"""
    for elem in array
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  onGuests:( event ) =>
    @guests = event.target.value
    # Util.log('Book.guests', @guests )
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

  onTest:() =>
    @stream.publish( "Alloc", Book.Alloc )

  onCell:( event ) =>
    $cell = $(event.target)
    $cell.removeClass().addClass("room-mine")
    Util.log( "Book.onCell", $cell.attr('id') )

  onAlloc:( alloc ) =>
    for     own roomId, book  of alloc
      for   own custId, cust  of book
        for own lookup, bdays of cust
          for day in cust.days
            @allocCell( roomId, day, cust.status )
    return

  allocCell:( roomId, day, lookup ) ->
    $('#'+roomId+day).removeClass().addClass("room-"+lookup)

  dayMonth:( iday ) ->
    day = @begDay + iday - 1
    if day > @numDayMonth[@monthIdx] then day-@numDayMonth[@monthIdx] else day

  toDateStr:( day ) ->
    @year+Util.pad(@monthIdx+5)+Util.pad(@dayMonth(day))
