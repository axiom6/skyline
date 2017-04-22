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
    for own    resKey, res     of resvs
      for own  roomId, resRoom of res.rooms
        room =  @room.rooms[roomId]
        for own dayId, resDay  of resRoom.days
          roomDay = room.days[dayId]
          roomDay = if roomDay? then roomDay else {}
          roomDay.status   = res.status
          roomDay.resKey   = resKey
          room.days[dayId] = roomDay

  createRes:( total, status, method, phone, roomUIs, payments ) ->
    res          = {}
    res.key      = @genResKey( roomUIs )
    res.total    = total
    res.paid     = 0
    res.balance  = 0
    res.status   = status
    res.method   = method
    res.booked   = '20170516' # @Data.today()
    res.arrive   = "99999999"
    res.custKey  = @Data.genCustKey( phone )
    res.rooms    = {}
    for own roomId, roomUI of roomUIs when roomUI.numDays > 0
      res.rooms[roomId] = roomUI.resRoom
      for own day, obj of roomUI.resRoom.days
        day.status = status if day.status is 'mine'
        res.arrive = day    if day < res.arrive
    res.payments = payments
    #@subscribeToResKey( res.key )
    res

  genResKey:( roomUIs ) ->
    resKey = ""
    #Util.log( 'Res.genResKey() 1', roomUIs )
    for own roomId, roomUI of roomUIs when roomUI.numDays > 0
      #Util.log( 'Res.genResKey() 2', roomId, roomUI.numDays, roomUI.resRoom.days )
      days   = Object.keys(roomUI.resRoom.days).sort()
      resKey = @Data.genResKey( roomId, days[0] )
      break
    Util.error('Res.genResKey() resKey blank' ) if not Util.isStr(resKey)
    resKey

  add:( id, res ) -> @store.add( 'Res', id, res )

  put:( id, res ) -> @store.put( 'Res', id, res )

  resRoom:() -> { "total":0, "price":0, "guests":2, "pets":0, "spa":false, "days":{} }
  resPay:()  -> { "amount":0,"date":"xxxxxxxx", "with":"xxxxx", "num":"xxxx" }


