
$    = require( 'jquery'     )
Data = require( 'js/res/Data')

class Own

  module.exports = Own

  constructor:( @stream, @store, @room, @cust, @book ) ->
    #@subscribe()
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs

  ready:() ->
    $('#Season').append( @monthsHtml( ) )

  monthsHtml:() ->
    htm = ""
    for month in Data.months
      htm += """<div id="#{month}" class="#{month}">#{@monthTable(month)}</div>"""
    htm

  monthTable:( month ) ->
    monthIdx = Data.monthsAll.indexOf(month)
    begDay   = new Date( 2017, monthIdx, 1 ).getDay() - 1
    endDay   = Data.allDayMonth[monthIdx]
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
        color = if day is "|" then "white" else "black"
        htm  += """<td style="color:#{color};">#{@roomDay(day)}</td>"""
      htm += """</tr>"""
    htm += """</tbody></table>"""

  monthDay:( begDay, endDay, row, col ) ->
    day = row*7 + col - begDay
    day = if 1 <= day and day <= endDay then day else "|"
    day

  roomDay:( day ) ->
    htm = ""
    htm += """<div class="MonthDay">#{day}</div>"""
    for   row in [0...2]
      htm += """<div class="MonthRoom">"""
      for col in [1..5]
        num  = row*5 + col
        num  = 'N' if num is  9
        num  = 'S' if num is 10
        htm += """<span>#{num}</span>"""
      htm += """</div>"""
    htm



