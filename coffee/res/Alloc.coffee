
class Alloc

  module.exports = Alloc

  Alloc.Allocs   = require( 'data/Alloc.json' )

  constructor:( @stream, @store, @room, @cust, @master, @book=null ) ->
    @subscribe()
    @rooms = @room.rooms
    @init()

  init:() ->
    @store.make( 'Alloc' )

  #insert:() ->
  #  @store.insert( 'Alloc', Alloc.Allocs )

  subscribe:() ->
    @store.subscribe( 'Alloc', 'none', 'make',  (make)   => Util.log( 'Alloc.make()',  make   ) )
    @store.subscribe( 'Alloc', 'none', 'onAdd', (onAdd)  => @onAlloc(onAdd) )
    @store.subscribe( 'Alloc', 'none', 'onPut', (onPut)  => Util.log( 'Alloc.onPut()', onPut ) )
    @store.subscribe( 'Alloc', 'none', 'onDel', (onDel)  => Util.log( 'Alloc.onDel()', onDel ) )
    @store.make(      'Alloc' )
    @store.on( 'Alloc', 'onAdd' )
    @store.on( 'Alloc', 'onPut' )
    @store.on( 'Alloc', 'onDel' )

  onAlloc:( onAdd ) =>
    #Util.log( 'Alloc.onAlloc()', { onEvt:onAdd.onEvt, table:onAdd.table, key:onAdd.key, val:onAdd.val } )
    alloc  = onAdd.val
    roomId = onAdd.key
    @room.  onAlloc( alloc, roomId )
    @master.onAlloc( alloc, roomId )
    @book.  onAlloc( alloc, roomId ) if @book?
    return