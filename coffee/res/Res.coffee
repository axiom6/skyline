class Res

  module.exports = Res
  Res.Rooms  = require( 'data/room.json' )
  Res.Resvs  = {} #require( 'data/res.json'  )
  Res.Days   = {} #require( 'data/days.json' )
  Res.States = ["free","mine","depo","book"]

  constructor:( @stream, @store, @Data, @appName ) ->
    @rooms    = Res.Rooms
    @states   = Res.States
    @book     = null
    @master   = null
    @days     = {}
    beg       = @Data.toDateStr(   @Data.begDay )
    end       = @Data.advanceDate( beg, @Data.numDays-1 )
    @dateRange( beg, end ) if @appName is 'Guest'
    @populateMemory()      if @store.justMemory

  populateMemory:() ->
    @onResv(  'add', (resv) => console.log( 'onResv', resv ) )
    @onDays(  'put', (days) => console.log( 'onDays', days ) ) if @store.justMemory
    @insertNewTables() # Populate Memory

  dateRange:( beg, end, onComplete=null ) ->
    @store.subscribe( 'Days', 'range', 'none', (days) =>
      @days = days
      #console.log( 'Res.dateRange()', beg, end, @days )
      onComplete() if onComplete? )
    @store.range( 'Days', beg, end )
    return

  insertNewTables:() ->
    @insertRooms( Res.Rooms )
    @insertResvs( Res.Resvs )
    @insertDays(  Res.Resvs )

  getStatus:( roomId, date ) ->
    day   = if @days? then @days[date]
    entry = if  day?  and  day[roomId]? then day[roomId] else null
    if entry? then entry.status else 'free'

  resId:(    roomId, date ) ->
    day   = if @days? then @days[date]
    entry = if day? and day[roomId]? then day[roomId] else null
    if entry? then entry.resId else 'none' # Need to determine if resId == 'none' if the way to go

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
    roomUIs

  optSpa:( roomId ) -> @rooms[roomId].spa is 'O'
  hasSpa:( roomId ) -> @rooms[roomId].spa is 'O' or @rooms[roomId].spa is 'Y'

  createRoomResv:( status, method, totals, cust, roomUIs ) ->
    resv          = {}
    resv.resId    = @Data.genResId( roomUIs )
    resv.totals   = totals
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
    resv.cust     = cust
    #@subscribeToResId( resv.resId, 'add', (resv), Util.log( 'Resv', { resId:resv.resId, resv:resv )
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

  onResId:( op, doResv, resId ) => @store.on( 'Res',  op,  resId, (resv) => doResv(resv) )
  onResv:(  op, doResv        ) => @store.on( 'Res',  op, 'none', (resv) => doResv(resv) )
  onDays:(  op, doDay         ) => @store.on( 'Days', op, 'none', (day)  => doDay(day)   )

  insertRooms:( rooms ) =>
    @store.subscribe( 'Room', 'make', 'none', (make)  => @store.insert( 'Room', rooms ); Util.noop(make)  )
    @store.make( 'Room' )
    return

  insertResvs:( resvs ) ->
    @allocRooms( resv ) for own resId,  resv of resvs
    @store.subscribe( 'Res', 'make', 'none', () => @store.insert( 'Res', resvs ) )
    @store.make( 'Res' )
    return

  insertDays:( resvs ) ->
    @days = @createDaysFromResvs( resvs, {} )
    for own dayId, day of @days
      @store.add( 'Days', dayId, day )
    #console.log('Res.insertDays() days', @days  )
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
    payment.with    = method
    payment.last4   = last4
    payment.purpose = purpose
    payment.cc      = ''
    payment.exp     = ''
    payment.cvc     = ''
    payment

  setResvStatus:( resv, post, purpose ) ->
    if        post is 'post'
        resv.status = 'book' if purpose is 'PayInFull' or purpose is 'Complete'
        resv.status = 'depo' if purpose is 'Deposit'
    else if   post is 'deny'
        resv.status = 'free'
    if not Util.inArray(['book','depo','free'], resv.status )
      Util.error( 'Pay.setResStatus() unknown status ', resv.status )
      resv.status = 'free'
    resv.status

  postResv:( resv, post, amount, method, last4, purpose ) ->
    status = @setResvStatus( resv, post, purpose )
    if status is 'book' or status is 'depo'
      payId = @Data.genPaymentId( resv.resId, resv.payments )
      resv.payments[payId] = @createPayment( amount, method, last4, purpose )
      resv.paid   += amount
      resv.balance = resv.totals - resv.paid
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
