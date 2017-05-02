
class Room

  module.exports = Room
  Room.Rooms     = require( 'data/room.json' )
  Room.States    = ["free","mine","depo","book"]

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
      resRoom.name    = room.name
      resRoom.total   = 0
      resRoom.price   = 0
      resRoom.guests  = 2
      resRoom.pets    = 0
      resRoom.spa     = room.spa
      resRoom.days    = {}
      resRoom.group   = {} # All days in group at maintained at the same status
    roomUIs

  hasSpa:( roomId ) ->
    @rooms[roomId].spa > 0

  initRooms:() =>
    @store.subscribe( 'Room', 'none', 'make',  (make)  => @store.insert( 'Room', @rooms ); Util.noop(make)  )
    @store.make( 'Room' )

  dayBookedRm:( room, date ) ->
    day = room.days[date]
    if day? then day.status else 'free'

  dayBookedUI:( room, date ) ->
    day = room.resRoom.days[date]
    if day? then day.status else 'free'

  onAlloc:( alloc, roomId ) =>
    room = @rooms[roomId]
    for own day, obj of alloc.days
      room.days[day] =  alloc.days[day]
    @store.put( 'Room', roomId, room )
    return
