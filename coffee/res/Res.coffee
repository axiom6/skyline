class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json' )

  constructor:( @stream, @store, @Data, @room ) ->
    @testResvs = Res.Resvs
    @insertTestResvs() if @Data.testing

  subscribeToResId:( resId ) =>
    @store.subscribe( 'Res', resId, 'add', (add)  => Util.log('Res.subscribeToResId', resId, add ) )
    @store.subscribe( 'Res', resId, 'put', (put)  => Util.log('Res.subscribeToResId', resId, put ) )

  insertTestResvs:() ->
    @store.subscribe( 'Res', 'none', 'make',  (make) => @store.insert( 'Res', @testResvs ); Util.noop(make)  )
    @store.make( 'Res' )
    @updateRooms( @testResvs )
    return

  makeAllTables:() ->
    @store.make( 'Res'     )
    @store.make( 'Room'    )
    @store.make( 'Payment' )
    @store.make( 'Cust'    )

  # Need to clear out obsolete resKeys in rooms
  updateRooms:( resvs ) ->
    for   own  resId,  res     of resvs
      for own  roomId, resRoom of res.rooms
        room =  @room.rooms[roomId]
        for own dayId, resDay  of resRoom.days
          roomDay = room.days[dayId]
          roomDay = if roomDay? then roomDay else {}
          roomDay.status   = res.status
          roomDay.resId    = resId
          room.days[dayId] = roomDay

  createRoomRes:( total, status, method, roomUIs ) ->
    res          = {}
    res.resId    = @Data.genResId( roomUIs )
    res.total    = total
    res.paid     = 0
    res.balance  = 0
    res.status   = status
    res.method   = method
    res.booked   = @Data.today()
    res.arrive   = res.resId.substr(1,8)
    res.rooms    = {}
    for own roomId, roomUI of roomUIs when roomUI.numDays > 0
      res.rooms[roomId] = roomUI.resRoom
      for own day, obj of roomUI.resRoom.days
        day.status = status if day.status is 'mine'
        res.arrive = day    if day < res.arrive
    res.payments = {}
    res.cust     = {}
    #@subscribeToResKey( res.resId )
    res

  createCust:( first, last, phone, email, source ) ->
    cust = {}
    cust.custId = @Data.genCustId( phone )
    cust.first  = first
    cust.last   = last
    cust.phone  = phone
    cust.email  = email
    cust.source = source
    cust

  postAllRes:( id, res ) ->
    @updateAllRooms( res )
    @store.add(    'Res',     id, res )
    @store.insert( 'Room',    res.rooms )
    @store.insert( 'Payment', res.payments )
    @store.add(    'Cust',    res.cust.custId, res.cust )
