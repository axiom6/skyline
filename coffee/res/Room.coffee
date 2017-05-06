
class Room

  module.exports = Room
  Room.Rooms     = require( 'data/room.json' )
  Room.States    = ["free","mine","depo","book"]

  constructor:( @stream, @store, @Data ) ->
    @rooms   = Room.Rooms
    @states  = Room.States
    @initRooms()

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

  initRooms:() =>
    @store.subscribe( 'Room', 'none', 'make',  (make)  => @store.insert( 'Room', @rooms ); Util.noop(make)  )
    @store.make( 'Room' )

  dayBookedRm:( room, date ) ->
    day = room.days[date]
    if day? then day.status else 'free'

  dayBookedUI:( room, date ) ->
    day = room.days[date]
    if day? then day.status else 'free'

  onAlloc:( alloc, roomId ) =>
    room = @rooms[roomId]
    for own day, obj of alloc.days
      room.days[day] =  alloc.days[day]
    @store.put( 'Room', roomId, room )
    return
