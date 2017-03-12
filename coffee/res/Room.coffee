
class Room

  module.exports = Room
  Room.Data      = require( 'data/Room.json' )

  constructor:( @stream, @store ) ->
    @data = Room.Data
    @UIs  = @createUIs( @data )
    @subscribe()

  createUIs:( data ) ->
    UIs = {}
    for key, room of data
      UIs[key] = {}
    UIs

  # Depends on Firebase promises
  doRoom:() ->
    @make()
    .then( @insert() )
    .then( @select() )
    .then( @on()     )
    .then( @add()    )
    .then( @get()    )
    .then( @put()    )
    .then( @del()    )
    #then( @drop()   )
    return

  subscribe:() ->
    @store.subscribe( 'Room', 'none', 'make',   (make)   => Util.log( 'Room.make()',   make   ); @insert() )
    @store.subscribe( 'Room', 'none', 'insert', (insert) => Util.log( 'Room.insert()', insert ); @select() )
    @store.subscribe( 'Room', 'none', 'select', (select) => Util.log( 'Room.select()', select ); @onAdd(); @onPut(); @onDel(); @add() )
    @store.subscribe( 'Room', 'none', 'onAdd',  (onAdd)  => Util.log( 'Room.onAdd()',  onAdd  )  )
    @store.subscribe( 'Room', 'none', 'onPut',  (onPut)  => Util.log( 'Room.onPut()',  onPut  )  )
    @store.subscribe( 'Room', 'none', 'onDel',  (onDel)  => Util.log( 'Room.onDel()',  onDel  )  )
    @store.subscribe( 'Room', 'W',    'add',    (add)    => Util.log( 'Room.add()',    add    ); @get()  )
    @store.subscribe( 'Room', 'S',    'get',    (get)    => Util.log( 'Room.get()',    get    ); @put()  )
    @store.subscribe( 'Room', '7',    'put',    (put)    => Util.log( 'Room.put()',    put    ); @del()  )
    @store.subscribe( 'Room', '8',    'del',    (del)    => Util.log( 'Room.del()',    del    ); @show() )
    @store.subscribe( 'Room', 'none', 'show',   (show)   => Util.log( 'Room.show()',   show   ) )
    @store.subscribe( 'Room', 'none', 'drop',   (drop)   => Util.log( 'Room.drop()',   drop   ) )

  make:()   => @store.make(   'Room' )
  show:()   => @store.show(   'Room' )
  drop:()   => @store.drop(   'Room' )

  insert:() =>
    Util.log( 'Room.Data', key, room ) for own key, room of Room.Data
    @store.insert( 'Room', Room.Data )

  select:() => @store.select( 'Room' )

  add:()   => @store.add(     'Room', "W", @west() )
  get:()   => @store.get(     'Room', "S" )
  put:()   => @store.put(     'Room', "7", @west() )
  del:()   => @store.del(     'Room', "8" )

  onAdd:() => @store.on( 'onAdd', 'Room' )
  onPut:() => @store.on( 'onPut', 'Room' )
  onDel:() => @store.on( 'onDel', 'Room' )

  west:() =>
    { "name":"West Skyline", "pet":12,"spa": 0,"max": 4,"price":0,"1":135,"2":135,"3":145,"4":155 }