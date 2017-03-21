
class Room

  module.exports = Room
  Room.Rooms     = require( 'data/Room.json' )
  Room.States    = ["book","depo","hold","free"]

  constructor:( @stream, @store ) ->
    @rooms   = Room.Rooms
    @states  = Room.States
    @roomUIs = @createRoomUIs( @rooms )

  createRoomUIs:( data ) ->
    roomUIs = {}
    for key, room of data
      roomUIs[key] = {}
    roomUIs

  createCell:( room, date ) ->
    status = @dayBooked( room, date )
    """<td id="#{room.roomId+date}" class="room-#{status}" data-status="#{status}"></td>"""

  dayBooked:( room, date ) ->
    for status in @states when room[status]?
      for day  in room[status]
        return status if day is date
    'free'

  onAlloc:( alloc ) =>
    Util.log( 'Room.onAlloc()' )
    for status in @states when alloc[status]?
      for day  in alloc[status]
        @allocRoom( alloc, day, status )
    #@store.put( 'Room', alloc.roomId, alloc )
    return

  allocRoom:( alloc, day, status ) ->
    room         = @rooms[alloc.roomId]
    room[status] = if room[status]? then room[status] else []
    roomDays     = room[status]
    roomDays.push(day) if not Util.inArray(roomDays,day)

