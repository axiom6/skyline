
class Room

  module.exports = Room
  Room.Rooms     = require( 'data/room.json' )
  Room.States    = ["book","depo","hold","free"]

  constructor:( @stream, @store, @Data ) ->
    @rooms   = Room.Rooms
    @states  = Room.States
    @roomUIs = @createRoomUIs( @rooms )
    @initRooms()

  createRoomUIs:( rooms ) ->
    roomUIs = {}
    for key, room of rooms
      roomUIs[key]    = {}
      roomUI          = roomUIs[key]
      roomUI.numDays  = 0
      roomUI.$        = {}
      roomUI.resRoom  = {}
      resRoom         = roomUI.resRoom
      resRoom.total   = 0
      resRoom.price   = 0
      resRoom.guests  = 2
      resRoom.pets    = 0
      resRoom.spa     = false
      resRoom.days    = {}
    roomUIs

  # { "total":0, "price":0, "guests":2,"pets":0, "spa":false, "days":{} },

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
