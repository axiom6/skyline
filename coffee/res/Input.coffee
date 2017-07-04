
$ = require( 'jquery'  )

class Input

  module.exports = Input

  constructor:( @stream, @store, @Data, @res, @master ) ->
    @resv  = {}
    @state = 'add'

  readyInput:() ->
    $('#ResAdd').empty()
    $('#ResAdd').append( @html() )
    $('#ResAdd').hide()
    @action()

  createResv:( arrive, stayto, roomId ) ->
    @resv = {}
    @resv.arrive = arrive
    @resv.stayto = stayto
    @resv.depart = @Data.advanceDate( stayto, 1 )
    @resv.roomId = roomId
    @resv.last   = ""
    @resv.status = 'Skyline'
    @resv.guests = 4
    @resv.pets   = 0
    @resv.booked = @Data.today()
    @state       = 'add'
    @refreshResv( @resv )
    return

  updateResv:(    arrive, stayto, roomId, resv ) ->
    @updateDates( arrive, stayto, roomId, resv )
    @resv = resv
    @state = 'put'
    @refreshResv( @resv )
    return

  updateDates:( arrive, stayto, roomId, resv ) ->
    return if @state isnt 'put' or not ( arrive? and stayto? and roomId? )
    beg = Math.min( arrive, stayto ).toString()
    end = Math.max( arrive, stayto ).toString()
    resv.arrive = beg if beg?
    resv.stayto = end if end?
    Util.log( 'Input.updateDates', beg, end, roomId )
    return
    
  html:() ->
    htm  = """<table id="NRTable"><thead>"""
    htm += """<tr><th>Arrive</th><th>Stay To</th><th>Room</th><th>Name</th>"""
    htm += """<th>Guests</th><th>Pets</th><th>Status</th>"""
    htm += """<th>Nights</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th><th>Action</th></tr>"""
    htm += """</thead><tbody>"""
    htm += """<tr><td id="NRArrive"></td><td id="NRStayTo"></td><td>#{@rooms()}</td><td>#{@names()}</td>"""
    htm += """<td>#{@guests()}</td><td>#{@pets()}</td><td>#{@status()}</td>"""
    htm += """<td id="NRNights"></td><td id="NRPrice"></td><td id="NRTotal"></td><td id="NRTax"></td><td id="NRCharge"></td>"""
    htm += """<td id="NRSubmit">#{@submit()}</td></tr>"""
    htm += """</tbody></table>"""
    htm
    
  action:() ->

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

  rooms: () -> @res.htmlSelect( 'NRRooms',  @res.roomKeys,      @resv.roomId  )
  guests:() -> @res.htmlSelect( 'NRGuests', @Data.persons,      4             )
  pets:  () -> @res.htmlSelect( 'NRPets',   @Data.pets,         0             )
  status:() -> @res.htmlSelect( 'NRStatus', @Data.statusesSel, 'Skyline'      )
  names: () -> @res.htmlInput(  'NRNames' )
  submit:() ->
    htm  = @res.htmlButton( 'NRCreate', 'NRSubmit', 'Create' )
    htm += @res.htmlButton( 'NRChange', 'NRSubmit', 'Change' )
    htm += @res.htmlButton( 'NRDelete', 'NRSubmit', 'Delete' )
    #tm += @res.htmlButton( 'NRCancel', 'NRSubmit', 'Cancel' )
    htm

  refreshResv:( resv ) ->
    resv.nights  = @Data.nights( resv.arrive, resv.depart )
    resv.price   = if resv.status is 'Skyline' or resv.status is 'Deposit' then @res.calcPrice(resv.roomId,resv.guests,resv.pets) else resv.price
    resv.deposit = resv.price * 0.5
    resv.total   = resv.nights * resv.price
    resv.tax     = parseFloat( Util.toFixed( resv.total * @Data.tax ) )
    resv.charge  = Util.toFixed( resv.total + resv.tax )
    $('#NRArrive').text( @Data.toMMDD(resv.arrive)  )
    $('#NRStayTo').text( @Data.toMMDD(resv.stayto)  )
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
        @res.createResvSkyline( r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.pets )
      else if r.status is 'Booking' or 'Prepaid'
        @res.createResvBooking( r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.total, r.booked )
      else
        Util.error( 'Input.doRes() unknown status', r.status, r )
      @master.resMode = 'Create'
      return

    doDel = () =>
      @resv.status = 'Free'
      @res.updateDaysFromResv( @resv )
      @resv
      
    $('#NRCreate').click () =>
      if Util.isStr( @resv.last )
        resv = doRes()
        @res.addResv( resv )
      else
        alert( 'Incomplete Reservation' )
      return

    $('#NRChange').click () =>
      resv = doRes()
      @res.putResv( resv )
      return

    $('#NRDelete').click () =>
      resv = doDel()
      resv.status = 'Cancel'
      @res.delResv( resv )
      return

    $('#NRCancel').click () =>
      resv = doRes()
      resv.status = 'Cancel'
      @res.canResv( resv )
      return
    