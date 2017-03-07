
$ = require( 'jquery' )

class Book

  module.exports    = Book
  Book.Room         = require( 'data/Room.json'  )
  Book.Book         = require( 'data/Book.json'  )
  Book.Alloc        = require( 'data/Alloc.json' )
  Book.StatusLookup = { "f":"free", "h":"hold", "b":"book" }

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
    @pet         = 0
    @petPrice    = 12
    @today       = new Date()
    @monthIdx    = @today.getMonth()
    @monthIdx    = if 4 < @monthIdx and @monthIdx < 10 then @monthIdx else 0
    @year        = "2017"
    @month       = @months[@monthIdx] # if 4 < @monthIdx and @monthIdx < 10 then @months[@monthIdx] else "May"
    @begDay      =  1
    @weekdayIdx  = new Date( 2017, @monthIdx, 1 ).getDay()
    @numDays     = 14
    Util.log('Book Constructor' )

  ready:() ->
    $('#Inits').append( @initsHtml( ) )
    $('#Rooms').append( @roomsHtml( ) )
    $('#Guests').change( @onGuests )
    $('#Months').change( @onMonth  )
    $('#Days'  ).change( @onDay    )
    $('#Pets'  ).change( @onPets   )
    $('#Months').val(@month)
    $('#Days'  ).val(@day)
    $('#Test'  ).click( @onTest )
    for id, room of Book.Room
      room.$ = $('#'+id)
    @subscribe()

  subscribe:() ->
    @stream.subscribe( 'Alloc', (alloc) => @onAlloc( alloc ) )
    return

  initsHtml:() ->
    htm     = """<label class="init-font">  Guests:#{@htmlSelect(@persons,"Guests")}</label>"""
    htm    += """<label class="init-font">  Pets:#{@htmlSelect(@pets,"Pets")}</label>"""
    htm    += """<label class="init-font">Arrive:#{@htmlSelect(@months,"Months")+@htmlSelect(@days,"Days")+@year}</label>"""
    htm    += """<span  class="init-test" id="Test">Test</span>"""
    htm

  roomsHtml:( ) ->
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th id="NumGuests">#{@guests}</th>"""
    for day in [1..@numDays]
      weekday = @weekdays[(@weekdayIdx+day-1)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th></th></tr><tr><th>Cottage</th><th>Guests</th>"
    for day in [1..@numDays]
      htm += "<th>#{@dayMonth(day)}</th>"
    htm += "<th></th></tr></thead><tbody>"
    for id, room of Book.Room
      room.id = id
      htm += """<tr id="#{id}"><td>#{room.name}</td><td id="P#{id}" class="room-price">#{'$'+room[@guests]}</td>"""
      for day in [1..@numDays]
        date = @year+Util.pad(@monthIdx+5)+Util.pad(@dayMonth(day))
        htm += @createCell( room, Book.Book[id], date )
      htm += """<td class="btn-book">Book</td></tr>"""
    htm += "</tbody></table>"
    htm

  createCell:( room, book, date ) ->
    status = @dayBooked( book, date )
    switch status
      when 'free' then """<td id="#{room.id+date}" class="room-free"></td>""" # free
      when 'hold' then """<td id="#{room.id+date}" class="room-hold"></td>""" # hold
      when 'book' then """<td id="#{room.id+date}" class="room-book"></td>""" # book
      else          """<td id="#{room.id+date}" class="room-free"></td>""" # free

  allocCell:( room, book, date ) ->
    status = @dayBooked( book, date )
    $('#'+room.id+date).removeClass().addClass("room-"+status)

  updatePrice:(  room, book, date ) ->
    if @guests > room.max
      room.$.hide()
    else
      room.$.show()
      if not @dayBooked( book, date )
        price = room[@guests]+@pet*@petPrice
        $('#P'+room.id).text("#{'$'+price}")
    return

  updatePrices:() ->
    for id, room of Book.Room
      for day in [1..@numDays]
        date = @year+Util.pad()+Util.pad(@dayMonth(day))
        @updatePrice( room, Book.Book[id], date )

  toDay:( date ) ->
    if date.charAt(6) is '0' then date.substr(7,8) else date.substr(6,8)

  dayBooked:( book, day ) ->
    for key, bdays of book
      for bday in bdays when bday.substr(0,8) is day
        lookup = Book.StatusLookup[bday.substr(8,1)]
        return if lookup? then lookup else 'free'
    'free'

  htmlSelect:( array, prop  ) ->
    htm  = """<select id="#{prop}">"""
    for elem in array
      htm += "<option>#{elem}</option>"
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
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml( ) )
    return

  onDay:( event ) =>
    @begDay = parseInt(event.target.value)
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml( ) )
    return

  onPets:( event ) =>
    @pet = event.target.value
    @updatePrices()
    return

  onTest:() =>
    Util.log( "OnTest" )
    @stream.publish( "Alloc", Book.Alloc )

  onAlloc:( alloc ) =>
    Util.log( "onAlloc", alloc )
    for id, room of Book.Room
      room.id = id
      for day in [1..@numDays]
        date = @year+Util.pad(@monthIdx+5)+Util.pad(@dayMonth(day))
        @allocCell( room, alloc, date )
    return

  dayMonth:( iday ) ->
    day = @begDay + iday - 1
    if day > @numDayMonth[@monthIdx] then day-@numDayMonth[@monthIdx] else day
