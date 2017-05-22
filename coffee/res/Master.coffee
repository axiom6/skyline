
$ = require( 'jquery'  )

class Master

  module.exports = Master

  constructor:( @stream, @store, @Data, @res, @pay ) ->
    @rooms       = @res.rooms
    @res.master  = @
    @lastMaster  = { left:0, top:0, width:0, height:0 }
    @lastSeason  = { left:0, top:0, width:0, height:0 }

  ready:() ->
    beg = @Data.toDateStr(  1, 4 ) # May  1
    end = @Data.toDateStr( 31, 9 ) # Oct 31
    @res.dateRange( beg, end, @onDateRange )  # Call readyMaster
    #@selectToDays() if @store.justMemory
    @listenToDays()
    #listenToResv()
    $('#MasterBtn').click( @onMasterBtn )
    $('#SeasonBtn').click( @onSeasonBtn )
    $('#DailysBtn').click( @onDailysBtn )
    return

  onMasterBtn:() =>
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Master').show()
    return

  onLookup:( resv ) =>
    $('#Master').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Lookup').empty()
    Util.log( 'Master.onLookup', resv )
    $('#Lookup').append( @pay.confirmHead(  resv ) ) if not Util.isObjEmpty(resv)
    $('#Lookup').append( @pay.confirmTable( resv ) ) if not Util.isObjEmpty(resv)
    $('#Lookup').show()
    return

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Dailys').hide()
    $('#Season').append( @seasonHtml() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @onSeasonClick(event) )
    $('#Season').show()
    return

  onDailysBtn:() =>
    $('#Master').hide()
    $('#Lookup').hide()
    $('#Season').hide()
    $('#Dailys').append( @dailysHtml() ) if Util.isEmpty( $('#Dailys').children() )
    $('#Dailys').show()
    return

  readyMaster:() ->
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
    status = @res.dayBooked( roomId, date )
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
      status = @res.dayBooked( roomId, date )
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
