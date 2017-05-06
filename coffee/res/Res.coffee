class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json' )

  constructor:( @stream, @store, @Data, @room ) ->
    @testResvs = Res.Resvs
    @insertTestResvs() if @Data.testing

  createRoomResv:( status, method, roomUIs ) ->
    resv          = {}
    resv.resId    = @Data.genResId( roomUIs )
    resv.totals   = 0
    resv.paid     = 0
    resv.balance  = 0
    resv.status   = status
    resv.method   = method
    resv.booked   = @Data.today()
    resv.arrive   = resv.resId.substr(1,8)
    resv.rooms    = {}
    for own roomId, roomUI of roomUIs when not Util.isObjEmpty(roomUI.days)
      resv.rooms[roomId] = @toResvRoom( roomUI )
      for own day, obj of roomUI.days
        day.status = status if day.status is 'mine'
        resv.arrive = day   if day < resv.arrive
    resv.payments = {}
    resv.cust     = {}
    #@subscribeToResKey( resv,resId )
    resv

  toResvRoom:( roomUI ) ->
    room = {}
    room.name    = roomUI.name
    room.total   = roomUI.total
    room.price   = roomUI.price
    room.guests  = roomUI.guests
    room.pets    = roomUI.pets
    room.spa     = roomUI.spa
    room.change  = roomUI.change # Changes usually to spa opt out
    room.reason  = roomUI.reason
    room.days    = roomUI.days
    room.nights  = Util.keys(roomUI.days).length
    room

  # Need to clear out obsolete resKeys in rooms
  updateRooms:( resv ) ->
    for own  roomId, room of resv.rooms
      for own dayId, day  of room.days
        day.status = resv.status
        day.resId  = resv.resId
      delete room.group
      @allocRoom( roomId, room.days )

  allocRoom:( roomId, days ) ->
    @store.add( 'Alloc', roomId, { days:days } )

  subscribeToResId:( resId ) =>
    @store.subscribe( 'Res', resId, 'add', (add)  => Util.log('Res.subscribeToResId', resId, add ) )
    @store.subscribe( 'Res', resId, 'put', (put)  => Util.log('Res.subscribeToResId', resId, put ) )

  insertTestResvs:() ->
    @store.subscribe( 'Res', 'none', 'make',  (make) => @store.insert( 'Res', @testResvs ); Util.noop(make)  )
    @store.make( 'Res' )
    for own resId,  resv of  @testResvs
      @updateRooms( resv )
    return

  makeAllTables:() ->
    @store.make( 'Res'     )
    @store.make( 'Room'    )
    @store.make( 'Payment' )
    @store.make( 'Cust'    )

  createCust:( first, last, phone, email, source ) ->
    cust = {}
    cust.custId = @Data.genCustId( phone )
    cust.first  = first
    cust.last   = last
    cust.phone  = phone
    cust.email  = email
    cust.source = source
    cust

  createPayment:( amount, method, last4, purpose ) ->
    payment = {}
    payment.amount  = amount
    payment.date    = @Data.today()
    payment.method  = method
    payment.with    = last4
    payment.purpose = purpose
    payment.cc      = ''
    payment.exp     = ''
    payment.cvc     = ''
    payment

  setResvStatus:( resv, post, purpose ) ->
    if        post is 'post'
        resv.status = 'book' if purpose is 'PayInFull' or purpose is 'PayOffDeposit'
        resv.status = 'depo' if purpose is 'Deposit'
    else if   post is 'deny'
        resv.status = 'free'

    if not Util.inArray(['book','depo','free'], resv.status )
      Util.error( 'Pay.setResStatus() unknown status ', resv.status )
      resv.status = 'free'
    return    

  postResv:( resv, post, totals, amount, method, last4, purpose ) ->
    @setResvStatus( resv, post, purpose )
    payId = @Data.genPaymentId( resv.resId, resv.payments )
    resv.payments[payId] = @createPayment( amount, method, last4, purpose )
    resv.totals  = totals
    resv.paid   += amount
    resv.balance = totals - resv.paid
    @updateRooms( resv )
    if status is 'post'
      @store.add(    'Res',     resv.resId, resv )
      #store.insert( 'Room',    resv.rooms )
      #store.insert( 'Payment', resv.payments )
      #store.add(    'Cust',    resv.cust.custId, res.cust )
    Util.log('Res.postResv()', resv )

