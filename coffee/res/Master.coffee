
$      = require( 'jquery'        )
Upload = require( 'js/res/Upload' )

class Master

  module.exports = Master

  constructor:( @stream, @store, @Data, @res ) ->
    @rooms         = @res.rooms
    @upload        = new Upload( @stream, @store, @Data, @res )
    @resvNew       = {}
    @res.master    = @
    @dateBeg       = null
    @dateEnd       = null
    @resMode       = 'Table' # or 'Input'
    @roomId        = '1' # Need to consider roomId default
    @lastMaster    = { left:0, top:0, width:0, height:0 }
    @lastSeason    = { left:0, top:0, width:0, height:0 }

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
    return

  onResvTable:( resvs ) =>
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvTable(resvs) )

  onSeasonBtn:() =>
    $('#Master').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @seasonHtml() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @onSeasonClick(event) )
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
    $('#ResAdd').empty()
    $('#ResAdd').append( @resvInput() )
    $('#ResAdd').hide()
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

      if @resMode is 'Table' and @dateBeg?
        end = if @dateEnd?  then @dateEnd else @Data.advanceDate( @dateBeg, 3 )
        resvs = @res.resvRange(  @dateBeg, end )
        @onResvTable( resvs )
      else if @resMode is 'Input' and @dateBeg? and @dateEnd?
        @popResvInput( @dateBeg, @dateEnd, @roomId )

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
    doDays = (dayId,day) =>
      if dayId? and day? and not @res.days[dayId]
        @res.days[dayId] = day
        @onAlloc( dayId, day )
    @res.onDay( 'put',  doDays )
    return

  listenToResv:() =>
    doAdd = (resId,resv) =>
      if resId? and resv? and not @res.resvs[resId]
        @res.resvs[resId] = resv
    @res.onRes( 'add', doAdd )
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
