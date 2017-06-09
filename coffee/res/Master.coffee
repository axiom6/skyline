
$ = require( 'jquery'  )

class Master

  module.exports = Master

  constructor:( @stream, @store, @Data, @res, @pay ) ->
    @rooms         = @res.rooms
    @uploadedText  = ""
    @uploadedResvs = {}
    @res.master    = @
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
    @res.dateRange( @Data.beg, @Data.end, @readyMaster )
    return

  onMasterBtn:() =>
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Master').show()
    return

  onLookup:( resv ) =>
    $('#Master').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Lookup').empty()
    Util.log( 'Master.onLookup', resv )
    $('#Lookup').append( @pay.confirmHead(  resv          ) ) if not Util.isObjEmpty(resv)
    $('#Lookup').append( @pay.confirmTable( resv, 'Owner' ) ) if not Util.isObjEmpty(resv)
    $('#Lookup').show()
    return

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @seasonHtml() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @onSeasonClick(event) )
    $('#Season').show()
    return

  onDailysBtn:() =>
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Upload').hide()
    $('#Dailys').append( @dailysHtml() ) if Util.isEmpty( $('#Dailys').children() )
    $('#Dailys').show()
    return

  onUploadBtn:() =>
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
    $('#Master').append( @masterHtml() )
    $('.MasterTitle').click( (event) => @onMasterClick(event) )
    @readyCells()
    return

  readyCells:() ->
    doCell   = (event) =>
      $cell  = $(event.target)
      status = $cell.attr('data-status')
      resId  = $cell.attr('data-res'   )
      Util.log( 'doCell', { resId:resId, status:status } )
      if status isnt 'free'
        @res.onResId( 'get', @onLookup, resId )
        @store.get(   'Res', resId )
    $('[data-cell="y"]').click( doCell )
    return

  onDateRange:() =>
    @readyMaster()
    for own dayId, dayRoom of @res.days
      @onAlloc( dayId, dayRoom )
    return

  listenToDays:() =>
    doDays = (data) =>
      # dayId is onPut.key and dayRoom onPut.val
      console.log( 'Master.listenToDays()', data.key, data.val )
      @onAlloc( data.key, data.val )
    @res.onDays( 'put',    doDays )
    return

  selectToDays:() =>
    doDays = (days) =>
      console.log( 'Master.selectDays()', days )
      for own dayId, day of days
        @onAlloc( dayId, day )
    @res.onDays( 'select', doDays )
    @store.select( 'Days' )
    return

  listenToResv:() =>
    doAdd = (onAdd) =>
      resv = onAdd.val
      Util.log( 'Master.listenToResv() onAdd', resv )
      for   own roomId, room of resv.rooms
        for own  dayId, rday of room.days
          @onAlloc( dayId, rday )
    @res.onResv( 'add', doAdd )
    return

  onAlloc:(  dayId, dayRoom ) =>
    for own roomId, room   of dayRoom
      #console.log( 'Master.onAlloc', dayId, roomId, room )
      @allocMasterCell( roomId, dayId, room.status )
      @allocSeasonCell( roomId, dayId, room.status )
    return

  cellId:( pre,  date,  roomId ) ->
           pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  createMasterCell:(         roomId, date ) ->
    status = @res.getStatus( roomId, date )
    resId  = @res.resId(     roomId, date )
    """<td id="#{@cellId('M',date,roomId)}" class="room-#{status}" data-status="#{status}" data-res="#{resId}" data-cell="y"></td>"""

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
         Util.log('Master.onPaste()'  )
         Util.log(      @uploadedText )
         @uploadedResvs = @uploadParse(  @uploadedText )
         $('#UploadText').text( @uploadedText )
    document.addEventListener( "paste", onPaste )
    #ocument.getElementById("UploadText").addEventListener("paste", onPaste, false )

  uploadParse:( text ) ->
    obj   = {}
    return obj if not Util.isStr( text ) 
    lines = text.split('\n')
    for line in lines
      toks = line.split('\t')
      book           = {}
      resv           = {}
      book.nameg     = toks[0]
      book.arrive    = toks[1]
      book.depart    = toks[2]
      book.room      = toks[3]
      book.booked    = toks[4]
      book.status    = toks[5]
      book.total     = toks[6]
      book.commis    = toks[7]
      book.bookingId = toks[8]
      namesg         = book.nameg.split(' ')
      #resv.booking   = book
      resv.first     = namesg[0]
      resv.last      = namesg[1]
      resv.guests    = namesg[2].charAt(0)
      resv.arrive    = @toResvDate( book.arrive )
      resv.depart    = @toResvDate( book.depart )
      resv.pets      = 0
      resv.spa       = false
      resv.nights    = @Data.nights( resv.arrive, resv.depart )
      resv.roomId    = @toResvRoomId( book.room )
      resv.id        = resv.arrive + resv.roomId
      obj[resv.id]   = resv
      Util.log( 'Book......')
      Util.log(  book )
      Util.log( 'Resv......')
      Util.log(  resv )
    obj

  onUpdateRes:() =>
    return if Util.isObjEmpty( @uploadedResvs )
    resvs     = @updateResv( @uploadedResvs )
    @res.days = @res.createDaysFromResvs( resvs, @res.days ) # Not sure about this
    for own resId, resv of resvs
      @res.postResvChan( resv )
    @uploadedResv = {}

  updateResv:( uploadedResvs ) ->
    resvs = {}
    for own resId, u of uploadedResvs
      rooms = {}
      cust  = @res.createCust( u.first, u.last, "", "", "Booking" )
      days  = @res.createRoomDays( u.arrive, u.depart, 'chan', u.id )
      rooms[u.roomId] = @populateRoom( {}, days,  u.total, u.total/u.nights, u.guests, 0 )
      resv = @res.createRoomResv( 'chan', 'vcard', u.total, cust, rooms )
      resvs[resId] = resv
    resvs

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

  uploadTable:() ->
