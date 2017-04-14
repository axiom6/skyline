class Res

  module.exports = Res
  Res.Resvs      = require( 'data/res.json' )

  constructor:( @stream, @store, @room, @Data ) ->
    @testResvs = Res.Resvs
    @insertTestResvs() if @Data.testing

  subscribeToResId:( resId ) =>
    @store.subscribe( 'Res', resId, 'add', (add)  => Util.log(add)  )
    @store.subscribe( 'Res', resId, 'put', (put)  => Util.log(put)  )

  insertTestResvs:() ->
    @store.subscribe( 'Res', 'none', 'make',  (make) => @store.insert( 'Res', @testResvs ); Util.noop(make)  )
    @store.make( 'Res' )
    @updateRooms( @testResvs )
    return

  # Need to clear out obsolete resIds in rooms
  updateRooms:( resvs ) ->
    for own     resId, res     of resvs
      for own  roomId, resRoom of res.rooms
        room =  @room.rooms[roomId]
        for own dayId, resDay  of resRoom.days
          roomDay = room.days[dayId]
          roomDay = if roomDay? then roomDay else {}
          roomDay.status   = res.status
          roomDay.resId    = resId
          room.days[dayId] = roomDay

  createRes:( total, status, method, phone, roomUIs, payments ) ->
    res          = {}
    res.id       = @genResId( roomUIs )
    res.total    = total
    res.paid     = 0
    res.balance  = 0
    res.status   = status
    res.method   = method
    res.custId   = @Data.genCustId( phone )
    res.rooms    = {}
    for own roomId, roomUI of roomUIs when roomUI.numDays > 0
      res.rooms[roomId] = roomUI.resRoom
    res.payments = payments
    res

  genResId:( roomUIs ) ->
    resId = ""
    Util.log( 'Res.genResId() 1', roomUIs )
    for own roomId, roomUI of roomUIs when roomUI.numDays > 0
      Util.log( 'Res.genResId() 2', roomId, roomUI.numDays, roomUI.resRoom.days )
      days  = Object.keys(roomUI.resRoom.days).sort()
      resId = @Data.genResId( roomId, days[0] )
      break
    Util.error('Res.genResId() resId blank' ) if not Util.isStr(resId)
    resId

  add:( id, res ) -> @store.add( 'Res', id, res )

  put:( id, res ) -> @store.put( 'Res', id, res )

  resRoom:() -> { "total":0, "price":0, "guests":2, "pets":0, "spa":false, "days":{} }
  resPay:()  -> { "amount":0,"date":"xxxxxxxx", "with":"xxxxx", "num":"xxxx" }


