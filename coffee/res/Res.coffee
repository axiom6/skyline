class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json' )

  constructor:( @stream, @store, @room, @cust ) ->
    @resvs    = Res.Resvs
    @myResId  = '12'
    @myCustId = '12'
    @initRes()
    @updateRooms()

  initRes:() =>
    @store.subscribe( 'Res', @myResId, 'add', (add)  => Util.log(add)  )
    @store.subscribe( 'Res', @myResId, 'put', (put)  => Util.log(put)  )
    @store.subscribe( 'Res', 'none', 'make',  (make)  => @store.insert( 'Res', @resvs ); Util.noop(make)  )
    @store.make( 'Res' )

  # Need to clear out obsolete resIds in rooms
  updateRooms:() ->
    for own     resId, res     of @resvs
      for own  roomId, resRoom of res.rooms
        room =  @room.rooms[roomId]
        for own dayId, resDay  of resRoom.days
          roomDay = room.days[dayId]
          roomDay = if roomDay? then roomDay else {}
          roomDay.status   = res.status
          roomDay.resId    = resId
          room.days[dayId] = roomDay

  createHold:( total, status, method, custId, roomUIs, payments ) ->
    res = {}
    res.total    = total
    res.paid     = 0
    res.balance  = 0
    res.status   = status
    res.method   = method
    res.custId   = custId
    res.rooms    = {}
    for own roomId, roomUI of roomUIs when roomUI.numDays > 0
      res.rooms[roomId] = roomUI.resRoom
    res.payments = payments
    res

  add:( id, res ) -> @store.add( 'Res', id, res )

  put:( id, res ) -> @store.put( 'Res', id, res )

  resRoom:() -> { "total":0, "price":0, "guests":2, "pets":0, "spa":false, "days":{} }
  resPay:()  -> { "amount":0,"date":"xxxxxxxx", "with":"xxxxx", "num":"xxxx" }

###
    "1":{ "total":250, "paid":250, "balance":0,
    "rooms":  { "1":{ "total":250, "price":125, "guests":2,"pets":1, "spa":false, "days":{"20170709":{},"20170710":{} } } },
    "payments":{"1":{ "amount":250,"date":"20170517", "with":"check", "num":"4028" } },
    "status":"book", "method":"site", "custId":"1" },
onAlloc:( alloc, roomId ) =>
  room = @rooms[roomId]
  for own day, obj of alloc.days
    room.days[day] =  alloc.days[day]
  @store.put( 'Room', roomId, room )
  return
###
