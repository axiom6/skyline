
$    = require( 'jquery'     )
Data = require( 'js/res/Data')

class Master

  module.exports = Master

  constructor:( @stream, @store, @room, @cust ) ->
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs
    @year        = 2017
    @lastMaster  = { left:0, top:0, width:0, height:0 }
    @lastSeason = { left:0, top:0, width:0, height:0 }

  ready:() ->
    $('#Master').append( @masterHtml() )
    $('#Season').append( @seasonHtml() )
    $('.MasterTitle').click( (event) => @onMasterClick(event) )
    $('.SeasonTitle').click( (event) => @onSeasonClick(event) )
    return

  onAlloc:( alloc, roomId ) =>
    for own day, obj of alloc.days
      @allocMasterCell( roomId, day, obj.status )
      @allocSeasonCell( roomId, day, obj.status )
    return

  createMasterCell:( roomId,  room, date ) ->
    status = @room.dayBooked( room, date )
    """<td id="M#{roomId+date}" class="room-#{status}" data-status="#{status}"></td>"""

  allocMasterCell:( roomId, day, status ) ->
    @cellMasterStatus( $('#M'+roomId+day), status )

  allocSeasonCell:( roomId, day, status ) ->
    @cellSeasonStatus( $('#S'+roomId+day), status )

  cellMasterStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)

  cellSeasonStatus:( $cell, status ) ->
    $cell.removeClass().addClass("own-"+status).attr('data-status',status)

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

  masterHtml:() ->
    htm = ""
    for month in Data.season
      htm += """<div id="#{month}" class="#{month}">#{@roomsHtml( @year, month )}</div>"""
    htm

  roomsHtml:( year, month ) ->
    monthIdx   = Data.months.indexOf(month)
    begDay     = if month isnt 'May'     then 1 else 17
    endDay     = if month isnt 'October' then Data.numDayMonth[monthIdx] else 15
    weekdayIdx = new Date( year, monthIdx, 1 ).getDay()
    htm  = """<div class="MasterTitle">#{month}</div>"""
    htm += "<table><thead>"
    htm += """<tr><th></th>"""
    for day in [begDay..endDay]
      weekday = Data.weekdays[(weekdayIdx+day-1)%7].charAt(0)
      htm += "<th>#{weekday}</th>"
    htm  += "</tr><tr><th></th>"
    for day in [begDay..endDay]
      htm += "<th>#{day}</th>"
    htm  += "</tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td>#{roomId}</td>"""
      for day in [begDay..endDay]
        date = @toDateStr(monthIdx,day)
        htm += @createMasterCell( roomId, room, date )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  seasonHtml:() ->
    htm = ""
    for month in Data.season
      htm += """<div id="#{month}" class="#{month}C">#{@monthTable(month)}</div>"""
    htm

  monthTable:( month ) ->
    monthIdx = Data.months.indexOf(month)
    begDay   = new Date( 2017, monthIdx, 1 ).getDay() - 1
    endDay   = Data.numDayMonth[monthIdx]
    htm  = """<div class="SeasonTitle">#{month}</div>"""
    htm += """<table class="MonthTable"><thead><tr>"""
    for day in [0...7]
      weekday = Data.weekdays[day]
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
    htm = ""
    htm += """<div class="MonthDay">#{day}</div>"""
    htm += """<div class="MonthRoom">"""
    for col in [1..10]
      roomId = col
      roomId = 'N' if roomId is  9
      roomId = 'S' if roomId is 10
      status = @room.dayBooked( @room.rooms[roomId], @toDateStr(monthIdx,day) )
      if status isnt 'free'
        htm += """<span id="#{@roomDayId(monthIdx,day,roomId)}" class="own-#{status}">#{roomId}</span>"""
    htm += """</div>"""
    htm

  roomDayId:( monthIdx, day, roomId ) ->
    monPad = Util.pad( monthIdx+1 )
    dayPad = Util.pad( day )
    'S' + roomId + @year + monPad + dayPad

  monthDay:( begDay, endDay, row, col ) ->
    day = row*7 + col - begDay
    day = if 1 <= day and day <= endDay then day else ""
    day

  toDateStr:( monthIdx, day ) ->
    @year+Util.pad(monthIdx+1)+Util.pad(day)





