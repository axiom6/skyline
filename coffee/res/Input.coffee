
$ = require( 'jquery'  )

class Input

  module.exports = Input

  constructor:( @stream, @store, @Data, @res ) ->
    @resv = {}

  createResv:( arrive, stayto, roomId ) ->
    resv = {}
    resv.arrive = arrive
    resv.stayto = stayto
    resv.depart = @Data.advanceDate( stayto, 1 )
    resv.roomId = roomId
    resv.last   = ""
    resv.status = 'Skyline'
    resv.action = 'add'
    resv.guests = 4
    resv.pets   = 0

    @refreshResv( resv )
    @resv = resv
    return

  populateResv:(  resv ) ->
    @refreshResv( resv )
    @resv = resv
    return
    
  html:() ->
    htm  = """<table id="NRTable"><thead>"""
    htm += """<tr><th>Arrive</th><th>Stay To</th><th>Room</th><th>Name</th>"""
    htm += """<th>Guests</th><th>Pets</th><th>Status</th>"""
    htm += """<th>Nights</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th><th>Action</th></tr>"""
    htm += """</thead><tbody>"""
    htm += """<tr><td id="NRArrive"></td><td id="NRStayTo"></td><td id="NRRoomId"></td><td>#{@names()}</td>"""
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

  guests:() -> @res.htmlSelect( 'NRGuests', @Data.persons,      4        )
  pets:  () -> @res.htmlSelect( 'NRPets',   @Data.pets,         0        )
  status:() -> @res.htmlSelect( 'NRStatus', @Data.statusesSel, 'Skyline' )
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
    room         = '#' + resv.roomId
    room         = 'North' if resv.roomId is 'N'
    room         = 'South' if resv.roomId is 'S'
    $('#NRArrive').text( @Data.toMMDD(resv.arrive)  )
    $('#NRStayTo').text( @Data.toMMDD(resv.stayto)  )
    $('#NRRoomId').text( room                       )
    $('#NRNames' ).val(   resv.last   )
    $('#NRGuests').val(   resv.guests )
    $('#NRPets'  ).val(   resv.pets   )
    $('#NRStatus').val(   resv.status )
    $('#NRNights').text(  resv.nights )
    $('#NRPrice' ).text( '$'+resv.price  )
    $('#NRTotal' ).text( '$'+resv.total  )
    $('#NRTax'   ).text( '$'+resv.tax    )
    $('#NRCharge').text( '$'+resv.charge )
    if      resv.action is 'add'
      $('#NRCreate').show()
      $('#NRChange').hide()
      $('#NRDelete').hide()
    else if resv.action is 'put'
      $('#NRCreate').hide()
      $('#NRChange').show()
      $('#NRDelete').show()
    return

  resvSubmits:() ->

    doRes = () =>
      r = @resv
      @res.createResvSkyline( r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.pets )

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
    