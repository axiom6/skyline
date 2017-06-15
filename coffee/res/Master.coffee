
$ = require( 'jquery'  )

class Master

  module.exports = Master

  constructor:( @stream, @store, @Data, @res, @pay ) ->
    @rooms         = @res.rooms
    @uploadedText  = ""
    @uploadedResvs = {}
    @resvNew       = {}
    @res.master    = @
    @dateBeg       = null
    @dateEnd       = null
    @roomId        = '1' # Need to consider roomId default
    @lastMaster    = { left:0, top:0, width:0, height:0 }
    @lastSeason    = { left:0, top:0, width:0, height:0 }

  ready:() ->
    #@selectToDays() if @store.justMemory
    @listenToDays()
    #listenToResv()
    $('#MasterBtn').click( @onMasterBtn )
    $('#SeasonBtn').click( @onSeasonBtn )
    $('#DailysBtn').click( @onDailysBtn )
    $('#UploadBtn').click( @onUploadBtn )
    #res.dateRange( @Data.beg, @Data.end, @readyMaster ) # This works
    @res.selectAllDays( @readyMaster )
    return

  onMasterBtn:() =>
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#ResAdd').show()
    $('#ResTbl').show()
    $('#Master').show()
    return

  onLookup:( resv ) =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Lookup').empty()
    #Util.log( 'Master.onLookup', resv )
    $('#Lookup').append( @pay.confirmHead(  resv          ) ) if not Util.isObjEmpty(resv)
    $('#Lookup').append( @pay.confirmTable( resv, 'Owner' ) ) if not Util.isObjEmpty(resv)
    $('#Lookup').show()
    return

  onResvTable:( resvs ) =>
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvTable(resvs) )

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @seasonHtml() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @onSeasonClick(event) )
    $('#ResAdd').show()
    $('#ResTbl').show()
    $('#Season').show()
    return

  onDailysBtn:() =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Upload').hide()
    $('#Dailys').append( @dailysHtml() ) if Util.isEmpty( $('#Dailys').children() )
    $('#Dailys').show()
    return

  onUploadBtn:() =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').append( @uploadHtml() ) if Util.isEmpty( $('#Upload').children() )
    @bindUploadPaste()
    $('#UpdateRes').click( @onUpdateRes )
    $('#Upload').show()
    return

  readyMaster:() =>
    $('#ResAdd').empty()
    $('#ResAdd').append( @resvInput() )
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvTable( {} ) )
    $('#Master').empty()
    $('#Master').append( @masterHtml() )
    $('.MasterTitle').click( (event) => @onMasterClick(event) )
    @res.selectAllResvs( @readyCells )
    @resvInputRespond()
    return

  # Requires that @res.resvs to loaded
  readyCells:() =>
    doCell = (event) =>
      $cell    = $(event.target)
      status   = $cell.attr('data-status' )
      #resId   = $cell.attr('data-res'    )
      date     = $cell.attr('data-date'   )
      @roomId  = $cell.attr('data-roomId' )
      @dateBeg = if event.button is 0 then date else @dateBeg # Left  button
      @dateEnd = if event.button is 2 then date else @dateEnd # Right button
      @popResvInput( @dateBeg, @dateEnd, @roomId )
      if @dateBeg? and @dateEnd?
         resvs = @res.resvRange( @dateBeg, @dateEnd )
         @onResvTable( resvs )

    $('[data-cell="y"]').click(       doCell )
    $('[data-cell="y"]').contextmenu( doCell )
    return
    
  popResvInput:( arrive, stayto, roomId ) ->
    $('#arrive').text( @Data.toMMDD(arrive)  ) if arrive?
    $('#stayTo').text( @Data.toMMDD(stayto)  ) if stayto?
    $('#roomId').text( @roomId               )
    if arrive? and stayto?
      room   = @rooms[roomId]
      depart = @Data.advanceDate(    stayto, 1 )
      nights = @Data.nights( arrive, depart )
      price  = room.booking
      total  = nights * price
      tax    = parseFloat( Util.toFixed( total * @Data.tax ) )
      charge = Util.toFixed( total + tax )
      $('#nights').text( nights )
      $('#price' ).text( price  )
      $('#total' ).text( total  )
      $('#tax'   ).text( tax    )
      $('#charge').text( charge )
    return

  listenToDays:() =>
    doDays = (data) =>
      if data.key? and data.val?
        @onAlloc( data.key, data.val )
      else if data?
        Util.error( 'Master.listenToDays missing key val', data )
      else
        Util.error( 'Master.listenToDays missing data' )
    @res.onDay( 'put',    doDays )
    return

  selectToDays:() =>
    doDays = (days) =>
      #console.log( 'Master.selectDays()', days )
      @allocDays( days )
    @res.onDays( 'select', doDays )
    @store.select( 'Days' )
    return

  listenToResv:() =>
    doAdd = (onAdd) =>
      resv = onAdd.val
      @allocDays( resv.days )
    @res.onRes( 'add', doAdd )
    return

  allocDays:(  days ) =>
    @onAlloc(  dayId, day ) for own dayId, day of days
    return

  onAlloc:(  dayId, day ) =>
    date   = @Data.toDate( dayId )
    roomId = @Data.roomId( dayId )
    @allocMasterCell( roomId, date, day.status )
    @allocSeasonCell( roomId, date, day.status )
    return

  cellId:( pre,  date,  roomId ) ->
           pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  createMasterCell:( roomId, date ) ->
    day    = @res.day( date, roomId )
    status = day.status
    resId  = day.resId
    """<td id="#{@cellId('M',date,roomId)}" class="room-#{status}" data-status="#{status}" data-res="#{resId}" data-roomId="#{roomId}" data-date="#{date}" data-cell="y"></td>"""

  allocMasterCell:( roomId, date, status ) ->
    @cellMasterStatus( @$cell('M',date,roomId), status )
    return

  allocSeasonCell:( roomId, date, status ) ->
    @cellSeasonStatus( @$cell('S',date,roomId), status )
    return

  cellMasterStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)
    return

  cellSeasonStatus:( $cell, status ) ->
    $cell.removeClass().addClass( "own-"+status).attr('data-status',status)
    return

  onMasterClick:( event ) =>
    $title  = $(event.target)
    $month  = $title.parent()
    $master = $('#Master')
    if @lastMaster.height is 0
       $master.children().hide()
       @lastMaster = { left:$month.css('left'), top:$month.css('top'), width:$month.css('width'), height:$month.css('height') }
       $month.css( { left:0, top:0, width:'100%', height:'450px' } ).show()
    else
      $month.css( @lastMaster )
      $master.children().show()
      @lastMaster.height = 0
    return

  onSeasonClick:( event ) =>
    $title  = $(event.target)
    $month  = $title.parent()
    $season = $('#Season')
    if @lastSeason.height is 0
      $season.children().hide()
      @lastSeason = { left:$month.css('left'), top:$month.css('top'), width:$month.css('width'), height:$month.css('height') }
      $month.css( { left:0, top:0, width:'100%', height:'450px' } ).show()
    else
      $month.css( @lastSeason )
      $season.children().show()
      @lastSeason.height = 0
    return

  masterHtml:() ->
    htm = ""
    for month in @Data.season
      htm += """<div id="#{month}" class="#{month}">#{@roomsHtml( @Data.year, month )}</div>"""
    htm

  resvInput:() ->
    htm  = """<table><thead>"""
    htm += """<tr><th>Arrive</th><th>Stay To</th><th>Room</th><th>Name</th><th>Guests</th><th>Pets</th><th>Status</th><th></th><th>Nights</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th></tr>"""
    htm += """</thead><tbody>"""
    htm += """<tr><td id="arrive"></td><td id="stayTo"></td><td id="roomId"></td><td>#{@names()}</td><td>#{@guests()}</td><td>#{@pets()}</td><td>#{@status()}</td><td>#{@submit()}</td><td id="nights"></td><td id="price"></td><td id="total"></td><td id="tax"></td><td id="charge"></td></tr>"""
    htm += """</tbody></table>"""
    htm

  #nights:() -> @res.htmlSelect( 'nights',   @Data.nighti,   '2' )
  #roomi: () -> @res.htmlSelect( 'rooms',    @res.roomKeys,  '' )
  guests:() -> @res.htmlSelect( 'guests',   @Data.persons,   2 )
  pets:  () -> @res.htmlSelect( 'pets',     @Data.pets,      0   )
  status:() -> @res.htmlSelect( 'status',   @Data.statuses, 'chan' )
  names: () -> @res.htmlInput(  'Names',    'Names' )
  submit:() -> @res.htmlButton( 'Submit',   'Submit', 'Submit' )

  resvInputRespond:() ->
    #@res.makeSelect( 'Nights',   @resvNew )
    #@res.makeSelect( 'Rooms',    @resvNew )
    @res.makeSelect( 'guests',   @resvNew )
    @res.makeSelect( 'pets',     @resvNew )
    @res.makeSelect( 'status',   @resvNew )
    @res.makeInput(  'names',    @resvNew )
    $('#Submit').click (event) =>
      Util.noop( event )
      Util.log( @resvNew )

  resvTable:( resvs ) ->
    htm   = """<table><thead>"""
    htm  += """<tr><th>Arrive</th><th>Nights</th><th>Room</th><th>Name</th><th>Guests</th><th>Status</th><th>Booked</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th></tr>"""
    htm  += """</thead><tbody>"""
    for own resId, r of resvs
      Util.log( r )
      tax    = Util.toFixed( r.total * @Data.tax )
      charge = r.total + parseFloat( tax )
      htm += """<tr><td>#{r.arrive}</td><td>#{r.nights}</td><td>#{r.roomId}</td><td>#{r.last}</td><td>#{r.guests}</td><td>#{r.status}</td><td>#{r.booked}</td><td>#{r.price}</td><td>#{r.total}</td><td>#{tax}</td><td>#{charge}</td></tr>"""
    htm += """</tbody></table>"""
    htm

  roomsHtml:( year, month ) ->
    monthIdx   = @Data.months.indexOf(month)
    begDay     = 1                           # if month isnt 'May'     then 1 else 17
    endDay     = @Data.numDayMonth[monthIdx] # if month isnt 'October' then @Data.numDayMonth[monthIdx] else 15
    weekdayIdx = new Date( 2000+year, monthIdx, 1 ).getDay()
    htm  = """<div class="MasterTitle">#{month}</div>"""
    htm += "<table><thead>"
    htm += """<tr><th></th>"""
    for day in [begDay..endDay]
      weekday = @Data.weekdays[(weekdayIdx+day-1)%7].charAt(0)
      htm += "<th>#{weekday}</th>"
    htm  += "</tr><tr><th></th>"
    for day in [begDay..endDay]
      htm += "<th>#{day}</th>"
    htm  += "</tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td>#{roomId}</td>"""
      for day in [begDay..endDay]
        date = @Data.toDateStr( day, monthIdx )
        htm += @createMasterCell( roomId, date )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  seasonHtml:() ->
    htm = ""
    for month in @Data.season
      htm += """<div id="#{month}" class="#{month}C">#{@monthTable(month)}</div>"""
    htm

  monthTable:( month ) ->
    monthIdx = @Data.months.indexOf(month)
    begDay   = new Date( 2000+@res.year, monthIdx, 1 ).getDay() - 1
    endDay   = @Data.numDayMonth[monthIdx]
    htm  = """<div class="SeasonTitle">#{month}</div>"""
    htm += """<table class="MonthTable"><thead><tr>"""
    for day in [0...7]
      weekday = @Data.weekdays[day]
      htm += """<th>#{weekday}</th>"""
    htm += """</tr></thead><tbody>"""
    for row in [0...6]
      htm += """<tr>"""
      for col in [0...7]
        day   = @monthDay( begDay, endDay, row, col )
        htm  += if day isnt "" then """<td>#{@roomDay(monthIdx,day)}</td>""" else """<td></td>"""
      htm += """</tr>"""
    htm += """</tbody></table>"""

  roomDay:( monthIdx, day ) ->
    htm  = ""
    htm += """<div class="MonthDay">#{day}</div>"""
    htm += """<div class="MonthRoom">"""
    for col in [1..10]
      roomId = col
      roomId = 'N' if roomId is  9
      roomId = 'S' if roomId is 10
      date   = @Data.toDateStr( day, monthIdx )
      status = @res.getStatus( roomId, date )
      #Util.log('Master.roomDay()', date, roomId, status ) if date is '170524'
      if status isnt 'free'
        htm += """<span id="#{@roomDayId(monthIdx,day,roomId)}" class="own-#{status}">#{roomId} data-res="y"</span>"""
    htm += """</div>"""
    htm

  roomDayId:(  monthIdx,  day, roomId ) ->
    date = @Data.dateStr( day, monthIdx )
    @cellId( 'S', roomId, date )

  monthDay:( begDay, endDay, row, col ) ->
    day = row*7 + col - begDay
    day = if 1 <= day and day <= endDay then day else ""
    day

  dailysHtml:() ->
    htm  = ""
    htm += """<h1 class="DailysH1">Daily Activities</h1>"""
    htm += """<h2 class="DailysH2">Arrivals</h2>"""
    htm += """<h2 class="DailysH2">Departures</h2>"""
    htm

  uploadHtml:() ->
    htm  = ""
    htm += """<h1 class="UploadH1">Upload Booking.com</h1>"""
    htm += """<button id="UpdateRes" class="btn btn-primary">Update Res</button>"""
    htm += """<textarea id="UploadText" class="UploadText" rows="50" cols="100"></textarea>"""
    htm

  bindUploadPaste:() ->
    onPaste = (event) =>
      if window.clipboardData and window.clipboardData.getData # IE
        @uploadedText = window.clipboardData.getData('Text')
      else if event.clipboardData and event.clipboardData.getData
        @uploadedText = event.clipboardData.getData('text/plain')
      event.preventDefault()
      if Util.isStr(    @uploadedText )
         #Util.log('Master.onPaste()'  )
         #Util.log(      @uploadedText )
         @uploadedResvs = @uploadParse(  @uploadedText )
         $('#UploadText').text( @uploadedText )
    document.addEventListener( "paste", onPaste )
    #ocument.getElementById("UploadText").addEventListener("paste", onPaste, false )

  uploadParse:( text ) ->
    resvs   = {}
    return obj if not Util.isStr( text ) 
    lines = text.split('\n')
    for line in lines
      toks = line.split('\t')
      continue if toks[0] is 'Guest name'
      book   = @bookFromToks( toks )
      resv   = @resvFromBook( book )
      resvs[resv.resId ] = resv
    resvs

  bookFromToks:( toks ) ->
    book           = {}
    book.names     = toks[0]
    book.arrive    = toks[1]
    book.depart    = toks[2]
    book.room      = toks[3]
    book.booked    = toks[4]
    book.status    = toks[5]
    book.total     = toks[6]
    book.commis    = toks[7]
    book.bookingId = toks[8]
    #Util.log( 'Book......')
    #Util.log(  book )
    book

  resvFromBook:( book ) ->
    names  = book.names.split(' ')
    arrive = @toResvDate( book.arrive )
    depart = @toResvDate( book.depart )
    booked = @toResvDate( book.booked )
    roomId = @toResvRoomId( book.room )
    #first = names[0]
    last   = names[1]
    status = @toStatus(   book.status )
    guests = @toNumGuests( names )
    total  = parseFloat( book.total.substr(3) )
    @res.createResvBooking( arrive, depart, booked, roomId, last, status, guests, total )

  onUpdateRes:() =>

    if not Util.isStr( @uploadedText )
      @uploadedText  = @Data.bookingResvs
      @uploadedResvs = @uploadParse(  @uploadedText )
      $('#UploadText').text( @uploadedText )

    return if Util.isObjEmpty(    @uploadedResvs )
    return if not @updateValid(   @uploadedResvs )
    #@updateVerbose(              @uploadedResvs )
    @res.updateResvs(             @uploadedResvs )
    @uploadedResv = {}

  updateValid:( uploadedResvs ) ->
    valid = true
    for own resId, u of uploadedResvs
      u.v  = true
      #.v &= Util.isStr( u.first )
      u.v &= Util.isStr( u.last  )
      u.v &= 1 <= u.guests and u.guests <= 12
      u.v &= @Data.isDate( u.arrive )
      u.v &= @Data.isDate( u.depart )
      u.v &= if typeof(pets) is 'number' then 0 <= u.pets   and u.pets   <=  4 else true
      u.v &= 0 <= u.nights and u.nights <= 28
      u.v &= Util.inArray( @res.roomKeys, u.roomId )
      u.v &=   0.00 <= u.total and u.total <= 8820.00
      u.v &= 120.00 <= u.price and u.price <=  315.00
      valid &= u.v
      #Util.log( 'Resv......', u.v )
      #Util.log(  u )
    Util.log( 'Master.updateValid()', valid )
    true

  updateVerbose:( uploadedResvs ) ->
    for own resId, u of uploadedResvs
      Util.log( 'last  ', u.last   ) if not   Util.isStr( u.last  )
      Util.log( 'guests', u.guests ) if not ( 1 <= u.guests and u.guests <= 12 )
      Util.log( 'arrive', u.arrive ) if not   @Data.isDate( u.arrive )
      Util.log( 'depart', u.depart ) if not   @Data.isDate( u.depart )
      #Util.log( 'pets  ', u.pets   ) if not if typeof(pets) is 'number' then 0 <= u.pets and u.pets <=  4 elae true
      Util.log( 'nights', u.nights ) if not ( 0 <= u.nights and u.nights <= 28 )
      Util.log( 'roomId', u.roomId ) if not   Util.inArray( @res.roomKeys, u.roomId )
      Util.log( 'total ', u.total  ) if not (   0.00 <= u.total and u.total <= 8820.00 )
      Util.log( 'price ', u.price  ) if not ( 120.00 <= u.price and u.price <=  315.00 )
    return


  toNumGuests:( names ) ->
    for i in [0...names.length] when names[i] is 'guest' or names[i] is 'guests'
      return names[i-1]
    return '0' # This will invalidate

  toResvDate:( bookDate ) ->
    toks  = bookDate.split(' ')
    year  = @Data.year
    month = @Data.months.indexOf(toks[1]) + 1
    day   = toks[0]
    year.toString() + Util.pad(month) + day

  toResvRoomId:( bookRoom ) ->
    toks  = bookRoom.split(' ')
    if toks[0].charAt(0) is '#'
       toks[0].charAt(1)
    else
       toks[2].charAt(0)

  toStatus:( bookingStatus ) ->
    switch   bookingStatus
      when 'OK'       then 'chan'
      when 'Canceled' then 'canc'
      else                 'unkn'


