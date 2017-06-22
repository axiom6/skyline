
$      = require( 'jquery'        )
Upload = require( 'js/res/Upload' )
Query  = require( 'js/res/Query'  )
Input  = require( 'js/res/Input'  )
Season = require( 'js/res/Season' )

class Master

  module.exports = Master

  constructor:( @stream, @store, @Data, @res ) ->
    @rooms         = @res.rooms
    @upload        = new Upload( @stream, @store, @Data, @res )
    @query         = new Query(  @stream, @store, @Data, @res )
    @input         = new Input(  @stream, @store, @Data, @res )
    @season        = new Season( @stream, @store, @Data, @res )
    @res.master    = @
    @dateBeg       = null
    @dateEnd       = null
    @resMode       = 'Table' # or 'Input'
    @roomId        = null
    @showingMonth  = 'Master'

  ready:() ->
    #@selectToDays() if @store.justMemory
    @listenToDays()
    #listenToResv()
    $('#MasterBtn').click( @onMasterBtn )
    $('#MakResBtn').click( @onMakResBtn )
    $('#SeasonBtn').click( @onSeasonBtn )
    $('#DailysBtn').click( @onDailysBtn )
    $('#UploadBtn').click( @onUploadBtn )
    #res.dateRange( @Data.beg, @Data.end, @readyMaster ) # This works
    @res.selectAllDays( @readyMaster )
    return

  onMasterBtn:() =>
    @resMode = 'Table'
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#ResAdd').hide()
    $('#ResTbl').show()
    $('#Master').show()
    return

  onMakResBtn:() =>
    @resMode = 'Input'
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#ResAdd').show()
    $('#ResTbl').hide()
    $('#Master').show()
    @fillInCells( @dateBeg, @dateEnd, @roomId, 'Mine', 'Free' )
    [@dateBeg,@dateEnd] = [null,null]
    return

  onResvTable:( resvs ) =>
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvTable(resvs) )

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @season.html() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @season.onClick(event) )
    $('#ResAdd').hide()
    $('#ResTbl').show()
    $('#Season').show()
    return

  onDailysBtn:() =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Season').hide()
    $('#Upload').hide()
    $('#Dailys').append( @dailysHtml() ) if Util.isEmpty( $('#Dailys').children() )
    $('#Dailys').show()
    return

  onUploadBtn:() =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').append( @upload.html() ) if Util.isEmpty( $('#Upload').children() )
    @upload.bindUploadPaste()
    $('#UpdateRes').click( @upload.onUpdateRes )
    $('#Upload').show()
    return

  readyMaster:() =>
    $('#Master').empty()
    $('#Master').append( @html() )
    $('#ResAdd').empty()
    $('#ResAdd').append( @input.html() )
    $('#ResAdd').hide()
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvTable( {} ) )
    @showMonth( @Data.month ) # Show the current month
    $('.PrevMonth').click( (event) => @onMonthClick(event) )
    $('.ThisMonth').click( (event) => @onMonthClick(event) )
    $('.NextMonth').click( (event) => @onMonthClick(event) )
    @res.selectAllResvs( @readyCells )
    @input.action()
    return

  # Requires that @res.resvs to loaded
  readyCells:() =>

    # Show Today's Reservations
    resvs = @res.resvRange( @Data.today() )
    @onResvTable( resvs )

    doCell = (event) =>

      $cell   = $(event.target)
      status  = $cell.attr('data-status' )
      date    = $cell.attr('data-date'   )
      @roomId = $cell.attr('data-roomId' )
      ###
      resId   = $cell.attr('data-res'    )
      resv    = @res.getResv( date, @roomId )
      title   = if resv? then resv.last + ' $' + resv.total else 'Free'
      $cell.attr('title', title ) # if title isnt 'Free'
      ###

      if      @resMode is 'Table'
        resvs = @res.resvRange(  date )
        @onResvTable( resvs )
      else if @resMode is 'Input'

        [@dateBeg,@dateEnd] = @mouseDates( date )
        if @fillInCells(     @dateBeg, @dateEnd, @roomId, 'Free', 'Mine' )
          @input.createResv( @dateBeg, @dateEnd, @roomId )
        else
          resv = @res.getResv( date, @roomId )
          if resv?
            resv.action = 'put'
            @input.populateResv( resv )
          else
            Util.error( 'Master.doCell() resv undefined for', { data:date, roomId:roomId } )
      return

    $('[data-cell="y"]').click(       doCell )
    $('[data-cell="y"]').contextmenu( doCell )
    return

  mouseDates:( date ) ->
    if @dateBeg? and @dateBeg <= date
       @dateEnd = date
    else
       @dateBeg = date
       @dateEnd = date
    [@dateBeg,@dateEnd]

  # Only fill in freeStatus cells return success
  fillInCells:(     begDate,     endDate,     roomId, freeStatus, fillStatus ) ->
    return if not ( begDate? and endDate? and roomId? )
    $cells  = []
    nxtDate = begDate
    while nxtDate <= endDate
      $cell = @$cell( 'M', nxtDate, roomId )
      cstat = $cell.attr('data-status' )
      if cstat is freeStatus or cstat is fillStatus or cstat is 'Cancel'
        $cells.push( $cell )
        nxtDate = @Data.advanceDate( nxtDate, 1 )
      else
        return false
    for $cell in $cells
       @$cellStatus( $cell, fillStatus )
    true

  $cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)

  listenToDays:() =>
    doDays = (dayId,day) =>
      if dayId? and day?
        @res.days[dayId] = day
        @onAlloc( dayId, day )
    @res.onDay( 'add',  doDays )
    @res.onDay( 'put',  doDays )
    return

  listenToResv:() =>
    doAdd = (resId,resv) =>
      if resId? and resv? and not @res.resvs[resId]
        @res.resvs[resId] = resv
    @res.onRes( 'add', doAdd )
    @res.onRes( 'put', doAdd )
    return

  selectToDays:() =>
    doDays = (days) =>
      #console.log( 'Master.selectDays()', days )
      @allocDays( days )
    @res.onDays( 'select', doDays )
    @store.select( 'Days' )
    return

  allocDays:(  days ) =>
    @onAlloc(  dayId, day ) for own dayId, day of days
    return

  onAlloc:(  dayId, day ) =>
    date   = @Data.toDate( dayId )
    roomId = @Data.roomId( dayId )
    @allocCell(        roomId, date, day.status )
    @season.allocCell( roomId, date, day.status )
    return

  cellId:( pre,  date,  roomId ) ->
      pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  createCell:( roomId, date ) ->
    day    = @res.day( date, roomId )
    status = day.status
    resId  = day.resId
    """<td id="#{@cellId('M',date,roomId)}" class="room-#{status}" data-status="#{status}" data-res="#{resId}" data-roomId="#{roomId}" data-date="#{date}" data-cell="y"></td>"""

  allocCell:( roomId, date, status ) ->
    @cellStatus( @$cell('M',date,roomId), status )
    return

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass("room-"+status).attr('data-status',status)
    return

  onMonthClick:( event ) =>
    @showMonth( $(event.target).text() )
    return

  showMonth:( month ) ->
    $master = $('#Master')
    if month is @showingMonth    # Show all Months
      @removeAllMonthStyles()
      $master.css(  { height:'700px' } )
      $master.children().show()
      @showingMonth = 'Master'
    else                          # Show selected month
      $master.children().hide()
      $master.css( { height:'300px' } )
      $('#'+month).css(  { left:0, top:0, width:'100%', height:'290px', fontSize:'14px' } ).show()
      @showingMonth = month
    return

  # Removes expanded style from month and goes back to the month's css selector
  removeAllMonthStyles:() ->
    $('#'+month).removeAttr('style') for month in @Data.season

  html:() ->
    htm = ""
    for month in @Data.season
      htm += """<div id="#{month}" class="#{month}">#{@roomsHtml( @Data.year, month )}</div>"""
    htm

  resvTable:( resvs ) ->
    htm   = """<table class="RTTable"><thead>"""
    htm  += """<tr><th>Arrive</th><th>Stay To</th><th>Nights</th><th>Room</th><th>Name</th><th>Guests</th><th>Status</th><th>Booked</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th></tr>"""
    htm  += """</thead><tbody>"""
    for own resId, r of resvs
      #Util.log( r )
      arrive = @Data.toMMDD(r.arrive)
      stayto = @Data.toMMDD(r.stayto)
      booked = @Data.toMMDD(r.booked)
      tax    = Util.toFixed( r.total * @Data.tax )
      charge = Util.toFixed( r.total + parseFloat(tax) )
      htm += """<tr>"""
      htm += """<td class="RTArrive">#{arrive}  </td><td class="RTStayto">#{stayto}</td><td class="RTNights">#{r.nights}</td>"""
      htm += """<td class="RTRoomId">#{r.roomId}</td><td class="RTLast"  >#{r.last}</td><td class="RTGuests">#{r.guests}</td>"""
      htm += """<td class="RTStatus">#{r.status}</td><td class="RTBooked">#{booked}</td><td class="RTPrice" >$#{r.price}</td>"""
      htm += """<td class="RTTotal" >$#{r.total}</td><td class="RTTax"   >$#{tax}  </td><td class="RTCharge">$#{charge} </td></tr>"""
    htm += """</tbody></table>"""
    htm

  roomsHtml:( year, month ) ->
    monthIdx   = @Data.months.indexOf(month)
    prevMonth  = if monthIdx > 4 then """<span class="PrevMonth">#{@Data.months[monthIdx-1]}</span>""" else ""
    nextMonth  = if monthIdx < 9 then """<span class="NextMonth">#{@Data.months[monthIdx+1]}</span>""" else ""
    begDay     = 1                           # if month isnt 'May'     then 1 else 17
    endDay     = @Data.numDayMonth[monthIdx] # if month isnt 'October' then @Data.numDayMonth[monthIdx] else 15
    weekdayIdx = new Date( 2000+year, monthIdx, 1 ).getDay()
    htm  = """<div class="MasterTitle">#{prevMonth}<span class="ThisMonth">#{month}</span>#{nextMonth}</div>"""
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
        htm += @createCell( roomId, date )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  dailysHtml:() ->
    htm  = ""
    htm += """<h1 class="DailysH1">Daily Activities</h1>"""
    htm += """<h2 class="DailysH2">Arrivals</h2>"""
    htm += """<h2 class="DailysH2">Departures</h2>"""
    htm
