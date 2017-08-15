
$    = require( 'jquery'      )
Data = require( 'js/res/Data' )
UI   = require( 'js/res/UI'   )

class Input

  module.exports = Input

  constructor:( @stream, @store, @res, @master ) ->
    @resv       = {}
    @state      = 'add'
    @lastResId  = 'none'

  readyInput:() ->
    $('#ResAdd').empty()
    $('#ResAdd').append( @html() )
    $('#ResAdd').hide()
    @action()

  createResv:( arrive, stayto, roomId ) ->
    [arrive,stayto] = @master.fillInCells( arrive, stayto, roomId, 'Free', 'Mine' )
    return if not ( arrive? and stayto? )
    @resv = {}
    @resv.arrive = arrive
    @resv.stayto = stayto
    @resv.depart = Data.advanceDate( stayto, 1 )
    @resv.roomId = roomId
    @resv.last   = ""
    @resv.status = 'Booking'
    @resv.guests = 4
    @resv.pets   = 0
    @resv.price  = @res.calcPrice(@resv.roomId,@resv.guests,@resv.pets,@resv.status)
    @resv.booked = Data.today()
    @state       = 'add'
    @refreshResv( @resv )
    return

  updateResv:( arrive, stayto, roomId, resv ) ->
    [arrive,stayto] = if resv.resId isnt @lastResId then [resv.arrive,resv.stayto] else [arrive,stayto]
    if @updateDates( arrive, stayto, roomId, resv )
      @resv = resv
      @state = 'put'
      @refreshResv( @resv )
      @lastResId = @resv.resId
    else
      alert( "Reservation Dates Not Free: Arrive#{arrive} StayTo:#{stayto} RoomId:##{roomId} Name:#{resv.last}" )
    return

  updateDates:( arrive, stayto, roomId, resv ) ->
    return false if not ( arrive? and stayto? and roomId? )
    beg = Math.min( arrive, stayto ).toString()
    end = Math.max( arrive, stayto ).toString()
    resv.arrive = beg if beg?
    resv.stayto = end if end?
    free = @res.datesFree( arrive, stayto, roomId, resv )
    #Util.log( 'Input.updateDates', beg, end, roomId, free )
    free
    
  html:() ->
    htm  = """<table id="NRTable"><thead>"""
    htm += """<tr><th>Arrive</th><th>Stay To</th><th>Room</th><th>Name</th>"""
    htm += """<th>Guests</th><th>Pets</th><th>Status</th>"""
    htm += """<th>Nights</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th><th>Action</th></tr>"""
    htm += """</thead><tbody>"""
    htm += """<tr><td>#{@arrive()}</td><td>#{@stayto()}</td><td>#{@rooms()}</td><td>#{@names()}</td>"""
    htm += """<td>#{@guests()}</td><td>#{@pets()}</td><td>#{@status()}</td>"""
    htm += """<td id="NRNights"></td><td id="NRPrice"></td><td id="NRTotal"></td><td id="NRTax"></td><td id="NRCharge"></td>"""
    htm += """<td id="NRSubmit">#{@submit()}</td></tr>"""
    htm += """</tbody></table>"""
    htm
    
  action:() ->

    toDate = ( mmdd ) =>
      [mi,dd] = Data.midd(mmdd)
      Data.toDateStr( dd, mi )

    onMMDD = ( htmlId, mmdd0, mmdd1 ) =>
      roomId  = @resv.roomId
      date0   = toDate( mmdd0 )
      date1   = toDate( mmdd1 )
      if htmlId is 'NRArrive'
        if date1 < date0
          @master.fillCell( roomId, date1, @resv.status )
        else
          dayId = Data.dayId( date0, roomId )
          @res.delDay( @res.days[dayId] )
          @master.fillCell( roomId, date0, 'Free' )
        @res.allocResv( @resv, 'Free' )
        @resv.arrive = date1
        @res.allocResv( @resv, @resv.status )
      else if htmlId is 'NRStayTo'
        if date1 > date0
          @master.fillCell( roomId, date1, @resv.status )
        else
          dayId = Data.dayId( date0, roomId )
          @res.delDay( @res.days[dayId] )
          @master.fillCell( roomId, date0, 'Free' )
        @resv.stayto = date1
      Util.log( 'Input.onMDD', htmlId, date0, date1, @resv.arrive, @resv.stayto )
      @refreshResv( @resv )
      return

    UI.onArrowsMMDD( 'NRArrive', onMMDD )
    UI.onArrowsMMDD( 'NRStayTo', onMMDD )

    $('#NRNames').change (event) =>
      @resv.last = event.target.value
      #Util.log('Last', @resv.last )
      return

    $('#NRRooms').change (event) =>
      @resv.roomId = event.target.value
      #Util.log('RoomId', @resv.roomId )
      @refreshResv( @resv )
      return

    $('#NRGuests').change (event) =>
      @resv.guests = event.target.value
      #Util.log('Guests', @resv.guests )
      @refreshResv( @resv )
      return

    $('#NRPets'  ).change (event) =>
      @resv.pets = event.target.value
      #Util.log('Pets', @resv.pets )
      @refreshResv( @resv )
      return

    $('#NRStatus').change (event) =>
      @resv.status = event.target.value
      #Util.log('Status', @resv.status )
      @refreshResv( @resv )
      return

    @resvSubmits()

  arrive:() -> UI.htmlArrows( 'NRArrive', 'NRArrive' )
  stayto:() -> UI.htmlArrows( 'NRStayTo', 'NRStayTo' )
  rooms: () -> UI.htmlSelect( 'NRRooms',  @res.roomKeys,      @resv.roomId )
  guests:() -> UI.htmlSelect( 'NRGuests', Data.persons,      4             )
  pets:  () -> UI.htmlSelect( 'NRPets',   Data.pets,         0             )
  status:() -> UI.htmlSelect( 'NRStatus', Data.statusesSel, 'Skyline'      )
  names: () -> UI.htmlInput(  'NRNames' )
  submit:() ->
    htm  = UI.htmlButton( 'NRCreate', 'NRSubmit', 'Create' )
    htm += UI.htmlButton( 'NRChange', 'NRSubmit', 'Change' )
    htm += UI.htmlButton( 'NRDelete', 'NRSubmit', 'Delete' )
    #tm += UI.htmlButton( 'NRCancel', 'NRSubmit', 'Cancel' )
    htm

  refreshResv:( resv ) ->
    resv.depart  = Data.advanceDate(resv.stayto,1)
    resv.nights  = Data.nights( resv.arrive, resv.depart )
    resv.price   = @res.calcPrice(resv.roomId,resv.guests,resv.pets,resv.status)
    resv.deposit = resv.price * 0.5
    resv.total   = resv.nights * resv.price
    resv.tax     = parseFloat( Util.toFixed( resv.total * Data.tax ) )
    resv.charge  = Util.toFixed( resv.total + resv.tax )
    $('#NRArrive').text( Data.toMMDD(resv.arrive) )
    $('#NRStayTo').text( Data.toMMDD(resv.stayto) )
    $('#NRNames' ).val(   resv.last   )
    $('#NRRooms' ).val(   resv.roomId )
    $('#NRGuests').val(   resv.guests )
    $('#NRPets'  ).val(   resv.pets   )
    $('#NRStatus').val(   resv.status )
    $('#NRNights').text(  resv.nights )
    $('#NRPrice' ).text( '$'+resv.price  )
    $('#NRTotal' ).text( '$'+resv.total  )
    $('#NRTax'   ).text( '$'+resv.tax    )
    $('#NRCharge').text( '$'+resv.charge )
    @master.setLast( resv.arrive, resv.roomId, resv.last )
    if      @state is 'add'
      $('#NRCreate').show()
      $('#NRChange').hide()
      $('#NRDelete').hide()
    else if @state is 'put'
      $('#NRCreate').hide()
      $('#NRChange').show()
      $('#NRDelete').show()
    return

  resvSubmits:() ->

    doRes = () =>
      r = @resv
      if      r.status is 'Skyline' or 'Deposit'
        r = @res.createResvSkyline( r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.pets )
      else if r.status is 'Booking' or 'Prepaid'
        r = @res.createResvBooking( r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.total, r.booked )
      else
        r = null
        alert( "Unknown Reservation Status: #{r.status} Name:#{r.last}" )
      @master.setLast( r.arrive, r.roomId, r.last )
      r

    doDel = () =>
      @res.deleteDaysFromResv( @resv )
      @resv
      
    $('#NRCreate').click () =>
      if Util.isStr( @resv.last )
        resv = doRes()
        @res.addResv( resv ) if resv?
      else
        alert( 'Incomplete Reservation' )
      return

    $('#NRChange').click () =>
      resv = doDel()
      resv = doRes()
      @res.putResv( resv ) if resv?
      return

    $('#NRDelete').click () =>
      resv = doDel()
      resv.status = 'Cancel'
      @res.delResv( resv )
      return

    $('#NRCancel').click () =>
      resv = doRes()
      resv.status = 'Cancel'
      @res.canResv( resv ) if resv?
      return
    