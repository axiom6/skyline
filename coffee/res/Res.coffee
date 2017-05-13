class Res

  module.exports = Res
  Res.Rooms  = require( 'data/room.json' )
  Res.Resvs  = require( 'data/res.json'  )
  Res.Days   = require( 'data/days.json' )
  Res.States = ["free","mine","depo","book"]

  constructor:( @stream, @store, @Data ) ->
    @rooms    = Res.Rooms
    @states   = Res.States
    @book     = null
    @master   = null
    @days     = null
    @today    = new Date()
    @monthIdx = @today.getMonth()
    @monthIdx = if 4 <=  @monthIdx and @monthIdx <= 9 then @monthIdx else 4
    @year     = @Data.year
    @month    = @Data.months[@monthIdx]
    @numDays  = 15
    @begMay   = 15
    @begDay   = if @month is 'May' then @begMay else 1
    @beg      = @toDateStr( @begDay )
    @end      = @Data.advanceDate( @beg, @numDays )
    @insertNewTables() if     @Data.insertNewTables
    @dateRange()       if not @Data.insertNewTables

  dateRange:( onComplete=null ) ->
    @beg = @toDateStr( @begDay )
    @end = @Data.advanceDate( @beg, @numDays )
    @store.subscribe( 'Days', 'none',  'range', (days) => @days = days; Util.log('Res.dateRange',days); onComplete() if onComplete? )
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

  allocRooms:( resv ) ->
    for own  roomId, room of resv.rooms
      for own dayId, day  of room.days
        @setDay( day, resv.status, resv.resId )
      delete room.group
      @allocRoom( roomId, room.days )

  allocRoom:( roomId, days ) ->
    @book.  onAlloc( roomId, days ) if @book?
    @master.onAlloc( roomId, days ) if @master?

  setDay:( day, status, resId ) ->
    day.status = status
    day.resId  = resId

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
    @days = @createDaysFromResvs( resvs, {} )
    @store.subscribe( 'Days', 'none', 'make',  () => @store.insert( 'Days', @days  ) )
    @store.make( 'Days' )
    @subscribeToDays()
    return

  createDaysFromResvs:( resvs, days ) ->
    for own resvId, resv of resvs
      days = @createDaysFromResv( resv, days )
    days

  createDaysFromResv:( resv, days ) ->
    for   own roomId, room of resv.rooms
      for own  dayId, rday of room.days
        day = @createDay( days, dayId, roomId )
        @setDay( day, rday.status, rday.resId )
    #Util.log('Res.createDaysFromResv() days', days  )
    days

  createDay:( days, dayId, roomId ) ->
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

    return    

  postResv:( resv, post, totals, amount, method, last4, purpose ) ->
    @setResvStatus( resv, post, purpose )
    payId = @Data.genPaymentId( resv.resId, resv.payments )
    resv.payments[payId] = @createPayment( amount, method, last4, purpose )
    resv.totals  = totals
    resv.paid   += amount
    resv.balance = totals - resv.paid
    @allocRooms( resv )
    if status is 'post'
      @store.add( 'Res', resv.resId, resv )
      @days = @postDays( resv, @days )

    Util.log('Res.postResv()', resv )

  postDays:( resv, allDays ) ->
    newDays = @createDaysFromResv( resv, {} )
    Util.log('Res.postDays()', newDays )
    @store.insert( 'Days', newDays )
    @mergeDays( allDays,   newDays )

  mergeDays:( allDays, newDays ) ->
    for own newDayId, newDay of newDays
      for own roomId, room   of newDay
        allDay = @createDay( allDays, newDayId, roomId )
        @setDay( allDay, room.status, room.resId )
    allDays

  dayMonth:( day ) ->
    monthDay = day + @begDay - 1
    if monthDay > @Data.numDayMonth[@monthIdx] then monthDay-@Data.numDayMonth[@monthIdx] else monthDay

  toDateStr:( day ) ->
    @year+Util.pad(@monthIdx+1)+Util.pad(@dayMonth(day))

  toAnyDateStr:( year, monthIdx, day ) ->
    year+Util.pad(monthIdx+1)+Util.pad(day)

  #store.insert( 'Payment', resv.payments )
  #store.add(    'Cust',    resv.cust.custId, res.cust )
