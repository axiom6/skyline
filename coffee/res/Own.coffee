
$    = require( 'jquery'     )
Data = require( 'js/res/Data')

class Own

  module.exports = Own

  constructor:( @stream, @store, @room, @cust, @book ) ->
    #@subscribe()
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs
    @year        = 2017

  ready:() ->
    #htm =
    #Util.log(htm)
    #('#Season').append( @monthsHtml() )
    $('#Master').append( @masterHtml() )
    return

  masterHtml:() ->
    htm = ""
    for month in Data.season
      monthIdx = Data.months.indexOf(month)
      numDays  = Data.numDayMonth[monthIdx]
      htm += """<div id="#{month}" class="#{month}">#{@roomsHtml( @year, monthIdx, 1, numDays )}</div>"""
    htm

  roomsHtml:( year, monthIdx, begDay, numDays ) ->
    weekdayIdx  = new Date( year, monthIdx, 1 ).getDay()
    htm   = "<table><thead>"
    htm  += """<tr><th></th>"""
    for day in [1..numDays]
      weekday = Data.weekdays[(weekdayIdx+day-1)%7].charAt(0)
      htm += "<th>#{weekday}</th>"
    htm  += "</tr><tr><th></th></tr></thead><tbody>"
    for day in [1..numDays]
      htm += "<th>#{@book.dayMonth(day,begDay)}</th>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td>#{roomId}</td>"""
      for day in [1..numDays]
        date = @toDateStr(day)
        htm += @book.createCell( room, date )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  monthsHtml:() ->
    htm = ""
    for month in Data.season
      htm += """<div id="#{month}" class="#{month}">#{@monthTable(month)}</div>"""
    htm

  monthTable:( month ) ->
    monthIdx = Data.months.indexOf(month)
    begDay   = new Date( 2017, monthIdx, 1 ).getDay() - 1
    endDay   = Data.numDayMonth[monthIdx]
    htm  = """<div class="MonthTitle">#{month}</div>"""
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
      status = @book.dayBooked( @book.rooms[roomId], @toDateStr(monthIdx,day) )
      if status isnt 'free'
        htm += """<span id="#{@roomDayId(monthIdx,day,roomId)}" class="own-#{status}">#{roomId}</span>"""
    htm += """</div>"""
    htm

  roomDay2:( monthIdx, day ) ->
    htm = ""
    htm += """<div class="MonthDay">#{day}</div>"""
    for   row in [0...2]
      htm += """<div class="MonthRoom">"""
      for col in [1..5]
        roomId = row*5 + col
        roomId = 'N' if roomId is  9
        roomId = 'S' if roomId is 10
        status = @book.dayBooked( @book.rooms[roomId], @toDateStr(monthIdx,day) )
        #Util.log( "Own.roomDay()", @roomDayId(monthIdx,day,roomId), status, @book.rooms[roomId] ) if monthIdx is 6 and day >= 9
        htm += """<span id="#{@roomDayId(monthIdx,day,roomId)}" class="own-#{status}">#{roomId}</span>"""
      htm += """</div>"""
    htm
    
  roomDayId:( monthIdx, day, roomId ) ->
    monPad = Util.pad( monthIdx+1 )
    dayPad = Util.pad( day )
    @year + monPad + dayPad + roomId


  monthDay:( begDay, endDay, row, col ) ->
    day = row*7 + col - begDay
    day = if 1 <= day and day <= endDay then day else ""
    day

  toDateStr:( monthIdx, day ) ->
    @year+Util.pad(monthIdx+1)+Util.pad(day)





