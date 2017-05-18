class Res

  module.exports = Res
  Res.Rooms  = require( 'data/room.json' )
  Res.Resvs  = require( 'data/res.json'  )
  Res.Days   = require( 'data/days.json' )
  Res.States = ["free","mine","depo","book"]

  constructor:( @stream, @store, @Data, @appName ) ->
    # Util.log( 'Res.Days', Res.Days )
    @rooms    = Res.Rooms
    @states   = Res.States
    @book     = null
    @master   = null
    @days     = null
    @beg      = @Data.toDateStr( @Data.begDay )
    @end      = @Data.advanceDate( @beg, @Data.numDays )
    @insertNewTables() if     @Data.insertNewTables
    @dateRange()       if not @Data.insertNewTables and @appName is 'Guest'

  dateRange:( onComplete=null ) ->
    @beg = @Data.toDateStr( @Data.begDay )
    @end = @Data.advanceDate( @beg, @Data.numDays-1 )
    @store.subscribe( 'Days', 'none',  'range', (days) =>
      @days = days
      onComplete() if onComplete? )
    @store.range( 'Days', @beg, @end )
    return

  insertNewTables:() ->
    @insertRooms( Res.Rooms )
    @insertRevs(  Res.Resvs )
    @insertDays(  Res.Resvs )

  dayBooked:( roomId, date ) ->
    day   = if @days? then @days[date]
    entry = if  day?  and  day[roomId] then day[roomId] else null
    if entry? then entry.status else 'free'

  createRoomUIs:( rooms ) ->
    roomUIs = {}
    for key, room of rooms
      roomUIs[key]   = {}
      roomUI         = roomUIs[key]
      roomUI.$       = {}
      roomUI.name    = room.name
      roomUI.total   = 0
      roomUI.price   = 0
      roomUI.guests  = 2
      roomUI.pets    = 0
      roomUI.spa     = room.spa
      roomUI.change  = 0         # Changes usually to spa opt out
      roomUI.reason  = 'No Changes'
      roomUI.days    = {}
      roomUI.group   = {} # All days in group at maintained at the same status
    roomUIs

  optSpa:( roomId ) -> @rooms[roomId].spa is 'O'
  hasSpa:( roomId ) -> @rooms[roomId].spa is 'O' or @rooms[roomId].spa is 'Y'

  createRoomResv:( status, method, roomUIs ) ->
    resv          = {}
    resv.resId    = @Data.genResId( roomUIs )
    resv.totals   = 0
    resv.paid     = 0
    resv.balance  = 0
    resv.status   = status
    resv.method   = method
    resv.booked   = @Data.today()
    resv.arrive   = resv.resId.substr(0,6)
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

  allocRooms:( resv ) ->
    for own  roomId, room of resv.rooms
      for own dayId, day  of room.days
        @setDayRoom( day, resv.status, resv.resId ) # setDayRoom also works for days in rooms
      delete room.group
      @allocRoom( roomId, room.days )

  allocRoom:( roomId, days ) ->
    @book.  onAlloc( roomId, days ) if @book?
    @master.onAlloc( roomId, days ) if @master?

  subscribeToResId:( resId ) =>
    @store.subscribe( 'Res',   resId,    'add',   (add) => Util.log('Res.subscribeToResId add',   resId,   add ) )
    #store.subscribe( 'Res',   resId,  'onAdd', (onAdd) => Util.log('Res.subscribeToResId onAdd', resId, onAdd ) )
    #store.subscribe( 'Res',   resId,  'onPut', (onPut) => Util.log('Res.subscribeToResId onPut', resId, onPut ) )
    #store.subscribe( 'Res',   resId,  'onDel', (onDel) => Util.log('Res.subscribeToResId onDel', resId, onDel ) )
    #store.on( 'Res', 'onAdd', resId )
    #store.on( 'Res', 'onPut', resId )
    #store.on( 'Res', 'onDel', resId )

  subscribeToResv:( doAdd ) =>
    @store.subscribe( 'Res',  'none',    'add',   (add) => doAdd(add)   )

  # Does not work because we are updating Day / dayId / roomId grandchildren instead of children
  subscribeToDays:( doPut ) =>
    @store.subscribe( 'Days', 'none',  'onPut', (onPut) => doPut(onPut) )
    @store.on(        'Days',          'onPut' )

  # Does not work because we are updating Day / dayId / roomId grandchildren instead of children
  subscribeToDays2:() =>
    #store.subscribe( 'Days', 'none',    'add',   (add) => Util.log('Res.subscribeToDays add',     add ) )
    #store.subscribe( 'Days', 'none',  'onAdd', (onAdd) => Util.log('Res.subscribeToDays onAdd', onAdd ) )
    #store.subscribe( 'Days', 'none',  'onPut', (onPut) => Util.log('Res.subscribeToDays onPut', onPut ) )
    #store.subscribe( 'Days', 'none',  'onPut', (onPut) => Util.log('Res.subscribeToDays onPut', onPut ) )
    #store.subscribe( 'Days', 'none',  'onDel', (onDel) => Util.log('Res.subscribeToDays onDel', onDel ) )
    #store.on(        'Days',          'onAdd' )
    #store.on(        'Days',          'onPut' )
    #store.on(        'Days',          'onDel' )

  insertRooms:( rooms ) =>
    @store.subscribe( 'Room', 'none', 'make',  (make)  => @store.insert( 'Room', rooms ); Util.noop(make)  )
    @store.make( 'Room' )
    return

  insertRevs:( resvs ) ->
    @allocRooms( resv ) for own resId,  resv of resvs
    @store.subscribe( 'Res', 'none', 'make',  () => @store.insert( 'Res', resvs ) )
    @store.make( 'Res' )
    return

  insertDays:( resvs ) ->
    @subscribeToDays()
    @days = @createDaysFromResvs( resvs, {} )
    for own dayId, day of @days
      @store.add( 'Days', dayId, day )
    return

  # Inexplicable this is randomly generating arrays on [roomId]
  insertDays2:( resvs ) ->
    @subscribeToDays()
    @days = @createDaysFromResvs( resvs, {} )
    @store.subscribe( 'Days', 'none', 'make',  () => @store.insert( 'Days', @days  ) )
    @store.make( 'Days' )
    return

  createDaysFromResvs:( resvs, days ) ->
    for own resvId, resv of resvs
      days = @createDaysFromResv( resv, days )
    days

  createDaysFromResv:( resv, days ) ->
    for   own roomId, room of resv.rooms
      for own  dayId, rday of room.days
        dayRoom = @createDayRoom( days, dayId, roomId )
        @setDayRoom( dayRoom, rday.status, rday.resId )
    #Util.log('Res.createDaysFromResv() days', days  )
    days

  # Inexplicable this maybe randomly generating arrays on [roomId]
  createDayRoom:( days, dayId, roomIdA ) ->
    roomId = roomIdA.toString()
    days[dayId]         = {} if not days[dayId]?
    days[dayId][roomId] = {}
    days[dayId][roomId]

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
    resv.status

  postResv:( resv, post, totals, amount, method, last4, purpose ) ->
    status = @setResvStatus( resv, post, purpose )
    if status is 'book' or status is 'depo'
      payId = @Data.genPaymentId( resv.resId, resv.payments )
      resv.payments[payId] = @createPayment( amount, method, last4, purpose )
      resv.totals  = totals
      resv.paid   += amount
      resv.balance = totals - resv.paid
      @allocRooms( resv )
      @store.add( 'Res', resv.resId, resv )
      @days = @mergePostDays( resv, @days )
   # Util.log('Res.postResv()', resv )

  mergePostDays:( resv, allDays) ->
    newDays = @createDaysFromResv( resv, {} )
    for own newDayId, newDay of newDays
      for own roomId, room   of newDay
        dayRoom = @createDayRoom( allDays, newDayId, roomId )
        @setDayRoom( dayRoom, room.status, room.resId )
        # We do not publish from Days with the newDayId+'/'+roomId grand child
        # Instead @allocRoom( resv ) is driven by resv
        @store.put( 'Days', newDayId+'/'+roomId, dayRoom )
    allDays

  # Used for Days / dayId / roomId and for Res / rooms[dayId] since both has status and resid properties
  setDayRoom:( dayRoom, status, resId ) ->
    dayRoom.status = status
    dayRoom.resId  = resId
