class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json' )

  constructor:( @stream, @store, @room, @Data ) ->
    @testResvs = Res.Resvs
    @insertTestResvs() if @Data.testing

  subscribeToResKey:( resKey ) =>
    @store.subscribe( 'Res', resKey, 'add', (add)  => Util.log('Res.subscribeToResKey', resKey, add ) )
    @store.subscribe( 'Res', resKey, 'put', (put)  => Util.log('Res.subscribeToResKey', resKey, put ) )

  insertTestResvs:() ->
    @store.subscribe( 'Res', 'none', 'make',  (make) => @store.insert( 'Res', @testResvs ); Util.noop(make)  )
    @store.make( 'Res' )
    @updateRooms( @testResvs )
    return

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


  add:( id, res ) -> @store.add( 'Res', id, res )

  put:( id, res ) -> @store.put( 'Res', id, res )

  resRoom:() -> { "total":0, "price":0, "guests":2, "pets":0, "spa":false, "days":{} }
  resPay:()  -> { "amount":0,"date":"xxxxxxxx", "with":"xxxxx", "num":"xxxx" }


