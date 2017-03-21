
class Room

  module.exports = Room
  Room.Rooms     = require( 'data/Room.json' )
  Room.States    = ["book","depo","hold","free"]

  constructor:( @stream, @store ) ->
    @rooms   = Room.Rooms
    @states  = Room.States
    @roomUIs = @createRoomUIs( @rooms )
    @initRooms()

  createRoomUIs:( data ) ->
    roomUIs = {}
    for key, room of data
      roomUIs[key] = {}
    roomUIs

  initRooms:() =>
    @store.subscribe( 'Room', 'none', 'make',  (make)  => @store.insert( 'Room', @rooms ); Util.noop(make)  )
    @store.make( 'Room' )

  dayBooked:( room, date ) ->
    day = room.days[date]
    if day? then day.status else 'free'

  onAlloc:( alloc, roomId ) =>
    room = @rooms[roomId]
    for own day, obj of alloc.days
      room.days[day] =  alloc.days[day]
    @store.put( 'Room', roomId, room )
    return


