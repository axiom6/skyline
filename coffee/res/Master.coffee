
$      = require( 'jquery'        )
Data   = require( 'js/res/Data'   )
UI     = require( 'js/res/UI'     )
Upload = require( 'js/res/Upload' )
Query  = require( 'js/res/Query'  )
Input  = require( 'js/res/Input'  )
Season = require( 'js/res/Season' )

class Master

  module.exports = Master

  constructor:( @stream, @store, @res ) ->
    @rooms         = @res.rooms
    @upload        = new Upload( @stream, @store, @res    )
    @query         = new Query(  @stream, @store, @res, @ )
    @input         = new Input(  @stream, @store, @res, @ )
    @season        = new Season( @stream, @store, @res    )
    @res.master    = @
    @dateBeg       = @res.today
    @dateEnd       = @res.today
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
    #res.dateRange( Data.beg, Data.end, @readyMaster ) # This works
    #res.selectAllDaysResvs( @readyMaster )
    @res.selectAllResvs(     @readyMaster, true )
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
    @dateEnd = @dateEnd
    #[@dateBeg,@dateEnd,@dateSel] = [null,null,"Beg"]
    return

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @season.html() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @season.onMonthClick(event) )
    @season.showMonth( Data.month ) # Show the current month
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
    $('#UploadRes').click( @upload.onUploadRes )
    $('#UploadCan').click( @upload.onUploadCan )
    $('#CreateRes').click( @upload.onCreateRes )
    $('#CreateDay').click( @upload.onCreateDay )
    $('#CreateCan').click( @upload.onCreateCan )
    $('#CustomFix').click( @upload.onCustomFix )
    $('#Upload').show()
    return

  readyMaster:() =>
    $('#Master').empty()
    $('#Master').append( @html() )
    @showMonth( Data.month ) # Show the current month
    $('.PrevMonth').click( (event) => @onMonthClick(event) )
    $('.ThisMonth').click( (event) => @onMonthClick(event) )
    $('.NextMonth').click( (event) => @onMonthClick(event) )
    @query.readyQuery()
    @input.readyInput()
    @readyCells()
    return

  readyCells:() =>

    @query.resvBody( @res.resvArrayByDate( Data.today() ) ) # Show Today's Reservations

    doCell = (event) =>
      @fillInCells( @dateBeg, @dateEnd, @roomId, 'Mine', 'Free' )
      $cell   = $(event.target)
      $cell   = if $cell.is('div') then $cell.parent() else $cell
      date    = $cell.attr('data-date'   )
      @roomId = $cell.attr('data-roomid' )
      return if not date? or not @roomId?
      [@dateBeg,@dateEnd,@dateSel] = @mouseDates(date)

      if @resMode is 'Table'
        @query.updateBody( @dateBeg, @dateEnd, 'arrive' )
      else if @resMode is 'Input'
        resv = @res.getResv( date, @roomId )
        if not resv?
          @input.createResv( @dateBeg, @dateEnd, @roomId )
        else
          @input.updateResv( @dateBeg, @dateEnd, @roomId, resv )
      return

    $('[data-cell="y"]').click(       doCell )
    $('[data-cell="y"]').contextmenu( doCell )
    return

  mouseDates:( date ) ->
    @res.order = 'Decend' # Will flip to 'Ascend'
    if        @dateEnd  < date
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
  # Also order dates if necessary
  fillInCells:( begDate, endDate, roomId, free, fill ) ->
    return [null,null] if not ( begDate? and endDate? and roomId? )
    beg    = Math.min( begDate, endDate ).toString()
    end    = Math.max( begDate, endDate ).toString()
    $cells = []
    next   = beg
    while next <= end
      $cell  = @$cell( 'M', next, roomId )
      status = @res.status( next, roomId )
      if status is free or status is fill or status is 'Cancel'
        $cells.push( $cell )
        next = Data.advanceDate( next, 1 )
      else
        return [null,null]
    for $cell in $cells
       @cellStatus( $cell, fill )
    [beg,end]

  listenToDays:() =>
    doDays = (dayId,day) =>
      if dayId? and day?
        @res.days[dayId] = day
        @onAlloc( dayId )
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
    @onAlloc(  dayId ) for own dayId, day of days
    return

  onAlloc:(  dayId ) =>
    date   = Data.toDate( dayId )
    roomId = Data.roomId( dayId )
    #Util.log( 'Master.onAlloc', date, roomId )
    @allocCell(        roomId, date )
    @season.allocCell( roomId, date ) if @season?
    return

  cellId:( pre,  date,  roomId ) ->
      pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  allocCell:( roomId, date ) ->
    klass  = @res.klass( date, roomId )
    @cellStatus( @$cell('M',date,roomId), klass )
    return

  fillCell:( roomId, date, klass ) ->
    @cellStatus( @$cell('M',date,roomId), klass )
    return

  cellStatus:( $cell, klass ) ->
    $cell.removeClass().addClass( "room-"+klass)
    $cell.css( { background:Data.toColor(klass) } )
    return

  onMonthClick:( event ) =>
    @showMonth( $(event.target).text() )
    return

  showMonth:( month ) ->
    $master = $('#Master')
    if month is @showingMonth    # Show all Months
      @removeAllMonthStyles()
      $master.css(  { height:'860px' } )
      $master.children().show()
      @showingMonth = 'Master'
    else                          # Show selected month
      $master.children().hide()
      $master.css( { height:'475px' } )
      $('#'+month).css(  { left:0, top:0, width:'100%', height:'475px', fontSize:'14px' } ).show()
      @showingMonth = month
    return

  # Removes expanded style from month and goes back to the month's css selector
  removeAllMonthStyles:() ->
    $('#'+month).removeAttr('style') for month in Data.season

  html:() ->
    htm = ""
    for month in Data.season
      htm += """<div id="#{month}" class="#{month}">#{@roomsHtml( Data.year, month )}</div>"""
    htm

  roomsHtml:( year, month ) ->
    monthIdx   = Data.months.indexOf(month)
    prevMonth  = if monthIdx > 4 then """<span class="PrevMonth">#{Data.months[monthIdx-1]}</span>""" else ""
    nextMonth  = if monthIdx < 9 then """<span class="NextMonth">#{Data.months[monthIdx+1]}</span>""" else ""
    begDay     = 1                           # if month isnt 'May'     then 1 else 17
    endDay     = Data.numDayMonth[monthIdx] # if month isnt 'October' then Data.numDayMonth[monthIdx] else 15
    weekdayIdx = new Date( 2000+year, monthIdx, 1 ).getDay()
    htm  = """<div   class="MasterTitle">#{prevMonth}<span class="ThisMonth">#{month}</span>#{nextMonth}</div>"""
    htm += """<table class="MonthTable"><thead>"""
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
        date = Data.toDateStr( day, monthIdx )
        htm += @createCell(  date, roomId )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  allocResv:( resv ) ->
    $cell = @$cell( 'M', resv.arrive, resv.roomId )
    $div  = $cell.find('div')
    $div.text( resv.last )
    return

  createCell:( date, roomId ) ->
    [yy,mi,dd] = Data.yymidd( date )
    resv   = @res.getResv( date, roomId )
    klass  = @res.klass(   date, roomId )
    bord   = @border(      date, roomId, resv, klass )
    last   = if resv? and ( resv.arrive is date or dd is 1 ) then "<div>#{resv.last}</div>" else ''
    htm    = """<td id="#{@cellId('M',date,roomId)}" class="room-#{klass}" style="#{bord}" """
    htm   += """data-roomid="#{roomId}" data-date="#{date}" data-cell="y">#{last}</td>""" # Lower case roomid
    htm

  border:( date, roomId,   resv, klass ) ->
    color = Data.toColor( klass )
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
      [ya,ma,da] = Data.yymidd( resv.arrive )
      [ys,ms,ds] = Data.yymidd( resv.stayto )
      if resv.arrive is date
        span = Math.min( resv.nights, endDay-dd+1 )
      else if ma isnt ms and ms is mi
        span = ds
      else
        span = 0
    span
