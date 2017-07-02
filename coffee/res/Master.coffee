
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
    @dateBeg       = @Data.today()
    @dateEnd       = @Data.today()
    @dateSel       = "End"
    @roomId        = null
    @resMode       = 'Table' # or 'Input'
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
    @res.selectAllDaysResvs( @readyMaster )
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
    @fillInCells( @dateBeg, @dateEnd, @roomId, 'Mine', 'Free' ) # Clear any previous fill
    [@dateBeg,@dateEnd,@dateSel] = [null,null,"Beg"]
    return

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @season.html() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @season.onMonthClick(event) )
    @season.showMonth( @Data.month ) # Show the current month
    $('#ResAdd').hide()
    $('#ResTbl').hide()
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
    $('#ResTbl').append( @resvHead() )
    @showMonth( @Data.month ) # Show the current month
    $('.PrevMonth').click( (event) => @onMonthClick(event) )
    $('.ThisMonth').click( (event) => @onMonthClick(event) )
    $('.NextMonth').click( (event) => @onMonthClick(event) )
    @resvSortClick( 'RHBooked', 'booked' )
    @resvSortClick( 'RHRoom' ,  'roomId' )
    @resvSortClick( 'RHArrive', 'arrive' )
    @resvSortClick( 'RHStayTo', 'stayto' )
    @resvSortClick( 'RHName',   'last'   )
    @resvSortClick( 'RHStatus', 'status' )
    @readyCells()
    @input.action()
    return

  resvSortClick:( id, prop ) ->
    $('#'+id).click( () => @resvBody( @res.resvArrayByProp( @dateBeg, @dateEnd, prop ) ) )

  readyCells:() =>

    # Show Today's Reservations
    @resvBody( @res.resvArrayByDate( @Data.today() ) )

    doCell = (event) =>
      @fillInCells( @dateBeg, @dateEnd, @roomId, 'Mine', 'Free' )
      $cell   = $(event.target)
      date    = $cell.attr('data-date'   )
      @roomId = $cell.attr('data-roomId' )
      return if not date?
      [@dateBeg,@dateEnd,@dateSel] = @mouseDates( date )
      if      @resMode is 'Table'
        @doResv( @dateBeg, @dateEnd, 'arrive' )
      else if @resMode is 'Input'
        if @fillInCells(     @dateBeg, @dateEnd, @roomId, 'Free', 'Mine' )
          @input.createResv( @dateBeg, @dateEnd, @roomId )
        else
          @doResvUpdate( date, @roomId )
      return

    $('[data-cell="y"]').click(       doCell )
    $('[data-cell="y"]').contextmenu( doCell )
    return

  doResvUpdate:( date, roomId ) ->
    resv = @res.getResv( date, roomId )
    if resv?
      resv.action = 'put'
      @input.populateResv( resv )
    #else
    #  Util.error( 'Master.doCell() resv undefined for', { data:date, roomId:roomId } )
    return

  doResv:( beg, end, prop ) ->
    $('#QArrive').text( @Data.toMMDD(beg) )
    $('#QStayTo').text( @Data.toMMDD(end) )
    resvs = {}
    if end?
      resvs = @res.resvArrayByProp( beg, end, prop )
    else
      resvs = @res.resvArrayByDate( beg )
    @resvBody( resvs )

  mouseDates:( date ) ->
    @res.order = 'Decend' # Will flip to 'Ascend'
    if   not  @dateBeg? and not @dateEnd? # Init for Input
              @dateBeg  = date
              @dateEnd  = date
    else if   @dateEnd  < date
              @dateEnd  = date
    else if   @dateBeg  > date
              @dateBeg  = date
    else if   @dateBeg <= date and date <= @dateEnd
      if      @dateSel is 'Beg'
              @dateBeg  =  date
              @dateSel  = 'End'
      else if @dateSel is 'End'
              @dateEnd  = date
              @dateSel  = 'Beg'
    #Util.log( 'Master.mouseDates()', @dateBeg, date, @dateEnd, @dateSel )
    [@dateBeg,@dateEnd,@dateSel]

  # Only fill in freeStatus cells return success
  fillInCells:(     begDate,     endDate,     roomId, free, fill ) ->
    return if not ( begDate? and endDate? and roomId? )
    $cells  = []
    nxtDate = begDate
    while nxtDate <= endDate
      $cell = @$cell( 'M',  nxtDate, roomId )
      status = @res.status( nxtDate, roomId )
      if status is free or status is fill or status is 'Cancel'
        $cells.push( $cell )
        nxtDate = @Data.advanceDate( nxtDate, 1 )
      else
        return false
    for $cell in $cells
       @cellStatus( $cell, fill, fill ) # We can use fillStatus is 3rd argument for color here
    true

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
    doDel = (resId,resv) =>
      if resId? and resv? and @res.resvs[resId]
        delete @res.resvs[resId]
    @res.onRes( 'add', doAdd )
    @res.onRes( 'put', doAdd )
    @res.onRes( 'del', doDel )
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
    @allocCell(        roomId, date )
    @season.allocCell( roomId, date )
    return

  cellId:( pre,  date,  roomId ) ->
      pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  allocCell:( roomId, date ) ->
    klass  = @res.klass( date, roomId )
    @cellStatus( @$cell('M',date,roomId), klass )
    return

  cellStatus:( $cell, klass ) ->
    $cell.removeClass().addClass("room-"+klass)
    return

  onMonthClick:( event ) =>
    @showMonth( $(event.target).text() )
    return

  showMonth:( month ) ->
    $master = $('#Master')
    if month is @showingMonth    # Show all Months
      @removeAllMonthStyles()
      $master.css(  { height:'800px' } )
      $master.children().show()
      @showingMonth = 'Master'
    else                          # Show selected month
      $master.children().hide()
      $master.css( { height:'330px' } )
      $('#'+month).css(  { left:0, top:0, width:'100%', height:'330px', fontSize:'14px' } ).show()
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

  resvHead:() ->
    htm   = """<div id="QDates"><span id="QArrive"></span><span id="QStayTo"></span></div>"""
    htm  += """<table class="RTTable"><thead><tr>"""
    htm  += """<th id="RHArrive">Arrive</th><th id="RHStayTo">Stay To</th><th id="RHNights">Nights</th><th id="RHRoom"  >Room</th>"""
    htm  += """<th id="RHName"  >Name</th>  <th id="RHGuests">Guests</th> <th id="RHStatus">Status</th><th id="RHBooked">Booked</th>"""
    htm  += """<th id="RHPrice" >Price</th> <th id="RHPrice" >Total</th>  <th id="RHTax"   >Tax</th>   <th id="RHCharge">Charge</th>"""
    htm  += """</tr></thead><tbody id="RTBody"></tbody></table>"""
    htm

  resvBody:( resvs ) ->
    $('#RTBody').empty()
    htm = ""
    for r in resvs
      arrive  = @Data.toMMDD(r.arrive)
      stayto  = @Data.toMMDD(r.stayto)
      booked  = @Data.toMMDD(r.booked)
      tax     = Util.toFixed( r.total * @Data.tax )
      charge  = Util.toFixed( r.total + parseFloat(tax) )
      trClass = if @res.isNewResv(r) then 'RTNewRow' else 'RTOldRow'
      htm += """<tr class="#{trClass}">"""
      htm += """<td class="RTArrive">#{arrive}  </td><td class="RTStayto">#{stayto}</td><td class="RTNights">#{r.nights}</td>"""
      htm += """<td class="RTRoomId">#{r.roomId}</td><td class="RTLast"  >#{r.last}</td><td class="RTGuests">#{r.guests}</td>"""
      htm += """<td class="RTStatus">#{r.status}</td><td class="RTBooked">#{booked}</td><td class="RTPrice" >$#{r.price}</td>"""
      htm += """<td class="RTTotal" >$#{r.total}</td><td class="RTTax"   >$#{tax}  </td><td class="RTCharge">$#{charge} </td></tr>"""
    $('#RTBody').append( htm )

  roomsHtml:( year, month ) ->
    monthIdx   = @Data.months.indexOf(month)
    prevMonth  = if monthIdx > 4 then """<span class="PrevMonth">#{@Data.months[monthIdx-1]}</span>""" else ""
    nextMonth  = if monthIdx < 9 then """<span class="NextMonth">#{@Data.months[monthIdx+1]}</span>""" else ""
    begDay     = 1                           # if month isnt 'May'     then 1 else 17
    endDay     = @Data.numDayMonth[monthIdx] # if month isnt 'October' then @Data.numDayMonth[monthIdx] else 15
    weekdayIdx = new Date( 2000+year, monthIdx, 1 ).getDay()
    htm  = """<div   class="MasterTitle">#{prevMonth}<span class="ThisMonth">#{month}</span>#{nextMonth}</div>"""
    htm += """<table class="MonthTable"><thead>"""
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
        htm += @createCell(  date, roomId )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  createCell:( date, roomId ) ->
    [yy,mi,dd] = @Data.yymidd( date )
    resv   = @res.getResv( date, roomId )
    klass  = @res.klass(   date, roomId )
    bord   = @border(      date, roomId, resv, klass )
    status = if resv? then resv.status else 'Free'
    resId  = if resv? then resv.resId  else 'none'
    last   = if resv? and ( resv.arrive is date or dd is 1 ) then "<div>#{resv.last}</div>" else ''
    htm    = """<td id="#{@cellId('M',date,roomId)}" class="room-#{klass}" style="#{bord} """
    htm   += """data-res="#{resId}" data-roomId="#{roomId}" data-date="#{date}" data-cell="y">#{last}</td>"""
    htm


  border:( date, roomId,   resv, klass ) ->
    color = @Data.toColor( klass )
    bord  = ""
    if resv?
      bord    = "background-color:#{color}; border-top: 2px solid black;     border-bottom:2px solid black;   "
      if date is resv.arrive
        bord += "background-color:#{color}; border-left: 2px solid black;    border-right:2px solid #{color}; "
      else if date is resv.stayto
        bord += "background-color:#{color}; border-right:2px solid black;    border-left:2px  solid #{color}; "
      else
        bord += "background-color:#{color}; border-right:2px solid #{color}; border-left:2px  solid #{color}; "
    else
      bord    = "border:1px solid black;"
    bord

  dailysHtml:() ->
    htm  = ""
    htm += """<h1 class="DailysH1">Daily Activities</h1>"""
    htm += """<h2 class="DailysH2">Arrivals</h2>"""
    htm += """<h2 class="DailysH2">Departures</h2>"""
    htm

  # Not Used
  calcSpan:( date, roomId, mi, dd, endDay ) ->
    span   = 1
    resv   = @res.getResv( date, roomId )
    if resv?
      [ya,ma,da] = @Data.yymidd( resv.arrive )
      [ys,ms,ds] = @Data.yymidd( resv.stayto )
      if resv.arrive is date
        span = Math.min( resv.nights, endDay-dd+1 )
      else if ma isnt ms and ms is mi
        span = ds
      else
        span = 0
    span

