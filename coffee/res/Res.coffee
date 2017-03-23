class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json' )

  constructor:( @stream, @store, @room, @cust ) ->
    @resvs   = Res.Resvs
    @initRes()
    @updateRooms()

  initRes:() =>
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

###
onAlloc:( alloc, roomId ) =>
  room = @rooms[roomId]
  for own day, obj of alloc.days
    room.days[day] =  alloc.days[day]
  @store.put( 'Room', roomId, room )
  return
###
