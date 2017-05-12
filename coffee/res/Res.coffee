class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json'  )
  Res.Days       = require( 'data/days.json' )

  constructor:( @stream, @store, @Data, @room ) ->
    @days   = {}
    @book   = null
    @master = null
    @insertRevs( Res.Resvs ) if @Data.testing
    @insertDays( Res.Resvs ) if @Data.testing


  dayBooked:( roomId, date ) ->
    day   = Res.Days[date]
    entry = if day? and day[roomId] then day[roomId] else null
    if entry? then entry.status else 'free'

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
    @subscribeToResId( resv.resId )
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
    @book.  onAlloc( roomId, days ) if @book?
    @master.onAlloc( roomId, days ) if @master?

  subscribeToResId:( resId ) =>
    @store.subscribe( 'Res',   resId,  'onAdd', (onAdd) => Util.log('Res.subscribeToResId onAdd', resId, onAdd ) )
    @store.subscribe( 'Res',   resId,  'onPut', (onPut) => Util.log('Res.subscribeToResId onPut', resId, onPut ) )
    @store.subscribe( 'Res',   resId,  'onDel', (onDel) => Util.log('Res.subscribeToResId onDel', resId, onDel ) )
    @store.on( 'Res', 'onAdd', resId )
    @store.on( 'Res', 'onPut', resId )
    @store.on( 'Res', 'onDel', resId )

  subscribeToDays:() =>
    @store.subscribe( 'Days', 'none',  'onAdd', (onAdd) => Util.log('Res.subscribeToDays onAdd', onAdd ) )
    @store.subscribe( 'Days', 'none',  'onPut', (onPut) => Util.log('Res.subscribeToDays onPut', onPut ) )
    @store.subscribe( 'Days', 'none',  'onDel', (onDel) => Util.log('Res.subscribeToDays onDel', onDel ) )
    @store.on(        'Days',          'onAdd' )
    @store.on(        'Days',          'onPut' )
    @store.on(        'Days',          'onDel' )

  insertRevs:( resvs ) ->
    @store.subscribe( 'Res', 'none', 'make',  () => @store.insert( 'Res', resvs ) )
    @store.make( 'Res' )
    for own resId,  resv of resvs
      @updateRooms( resv )
    return

  insertDays:( resvs ) ->
    for     own resvId, resv of resvs
      for   own roomId, room of resv.rooms
        Util.error( 'Res.insertDays', roomId ) if not Util.inArray(['1','2','3','4','5','6','7','8','N','S'], roomId )
        for own  dayId, rday of room.days
          day = @createDay( @days, dayId, roomId )
          day.status = rday.status
          day.resId  = rday.resId
    Util.log('Res.insertDaysResvs() days', Res.Days  )
    @store.subscribe( 'Days', 'none', 'make',  () => @store.insert( 'Days', Res.Days  ) )
    @store.make( 'Days' )
    @subscribeToDays()
    return

  @xdays = {
   x170709:{ r1:{ status:"book", resId:1707091 } },
   x170710:{ r1:{ status:"book", resId:1707091 }, r2:{ status:"depo", resId:1707102 } },
   x170711:{ r2:{ status:"depo", resId:1707102 }, r3:{ status:"book", resId:1707113 } },
   x170712:{ r3:{ status:"book", resId:1707113 }, r4:{ status:"book", resId:1707124 } },
   x170713:{ r4:{ status:"book", resId:1707124 } },
   x170714:{ r5:{ status:"depo", resId:1707145 } },
   x170715:{ r5:{ status:"depo", resId:1707145 }, r6:{ status:"book", resId:1707156 } },
   x170716:{ r6:{ status:"book", resId:1707156 }, r7:{ status:"book", resId:1707167 } },
   x170717:{ r7:{ status:"book", resId:1707167 }, r8:{ status:"book", resId:1707178 } },
   x170718:{ r8:{ status:"book", resId:1707178 }, rN:{ status:"book", resId:1707189 } },
   x170719:{ rN:{ status:"book", resId:1707189 }, rS:{ status:"book", resId:1707190 } },
   x170720:{ rS:{ status:"book", resId:1707190 } } }


  createDay:( days, dayId, roomId ) ->
    Util.log( 'Res.createDay() days null ') if not days?
    dayd = days[dayId]
    if not dayd?
      dayd = {}
      days[dayId] = dayd
    dayd[roomId] = {}
    dayd[roomId]

  makeAllTables:() ->
    @store.make( 'Res'     )
    @store.make( 'Room'    )
    @store.make( 'Days'    )
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
      @postDays( resv )
      #store.insert( 'Room',    resv.rooms )
      #store.insert( 'Payment', resv.payments )
      #store.add(    'Cust',    resv.cust.custId, res.cust )
    Util.log('Res.postResv()', resv )

  postDays:( resv ) ->
    for   own roomId, room of resv.rooms
      for own  dayId, dayr of room.days
        dayd        = {}
        dayd.status = dayr.status
        dayd.resId  = dayr.resId
        @store.add( 'Days/'+dayId, roomId, dayd )
