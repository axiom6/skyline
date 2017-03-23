
class Room

  module.exports = Room
  Room.Rooms     = require( 'data/room.json' )
  Room.States    = ["book","depo","hold","free"]

  constructor:( @stream, @store ) ->
    @rooms   = Room.Rooms
    @states  = Room.States
    @roomUIs = @createRoomUIs( @rooms )
    @initRooms()

  createRoomUIs:( rooms ) ->
    roomUIs = {}
    for key, room of rooms
      roomUIs[key] resRoom = @resRoom
      roomUIs[key].guests  = 2
      roomUIs[key].pets    = 0
      roomUIs[key].numDays = 0
      roomUIs[key].total   = 0
      roomUIs[key].days    = {}
    roomUIs

  c = { "total":0, "price":0, "guests":2, "pets":0, "spa":false, "days":{} }

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


