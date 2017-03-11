
class Room

  module.exports = Room
  Room.Data      = require( 'data/Room.json' )

  constructor:( @stream, @store ) ->
    @subscribe()

  subscribe:() ->
    @store.subscribe( 'Room', 'none', 'open',   (open)   => Util.log( 'Room.open()',   open   ) )
    @store.subscribe( 'Room', 'none', 'show',   (show)   => Util.log( 'Room.show()',   show   ) )
    @store.subscribe( 'Room', 'none', 'drop',   (drop)   => Util.log( 'Room.drop()',   drop   ) )
    @store.subscribe( 'Room', 'none', 'insert', (insert) => Util.log( 'Room.insert()', insert ) )
    @store.subscribe( 'Room', 'none', 'select', (select) => Util.log( 'Room.select()', select ) )
    @store.subscribe( 'Room', 'W',    'add',    (add)    => Util.log( 'Room.add()',    add    ) )
    @store.subscribe( 'Room', 'S',    'get',    (get)    => Util.log( 'Room.get()',    get    ) )
    @store.subscribe( 'Room', '7',    'put',    (put)    => Util.log( 'Room.put()',    put    ) )
    @store.subscribe( 'Room', '8',    'del',    (del)    => Util.log( 'Room.del()',    del    ) )

  open:()   -> @store.open(   'Room' )
  show:()   -> @store.show(   'Room' )
  drop:()   -> @store.drop(   'Room' )

  insert:() -> @store.insert( 'Room', Room.Data )
  select:() -> @store.select( 'Room' )

  add:()   -> @store.add(     'Room', "W", @west() )
  get:()   -> @store.get(     'Room', "S" )
  put:()   -> @store.put(     'Room', "7", @west() )
  del:()   -> @store.del(     'Room', "8" )

  west:() ->
    { "name":"West Skyline", "pet":12,"spa": 0,"max": 4,"price":0,"1":135,"2":135,"3":145,"4":155 }