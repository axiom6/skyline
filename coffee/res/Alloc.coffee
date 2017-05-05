
class Alloc

  module.exports = Alloc

  Alloc.Allocs   = require( 'data/Alloc.json' )

  constructor:( @stream, @store, @Data, @room=null, @book=null, @master=null ) ->
    @subscribe()
    @rooms = @room.rooms

  #insert:() ->
  #  @store.insert( 'Alloc', Alloc.Allocs )

  subscribe:() ->
    @store.subscribe( 'Alloc', 'none', 'make',  (make)   => Util.noop( 'Alloc.make()',  make  ) )
    @store.subscribe( 'Alloc', 'none', 'onAdd', (onAdd)  => @onAlloc(onAdd) )
    @store.subscribe( 'Alloc', 'none', 'onPut', (onPut)  => @onAlloc(onPut) )
    @store.subscribe( 'Alloc', 'none', 'onDel', (onDel)  => Util.noop( 'Alloc.onDel()', onDel ) )
    @store.make(      'Alloc' )
    @store.on( 'Alloc', 'onAdd' )
    @store.on( 'Alloc', 'onPut' )
    @store.on( 'Alloc', 'onDel' )

  onAlloc:( onAdd ) =>
    #Util.log( 'Alloc.onAlloc()', { onEvt:onAdd.onEvt, table:onAdd.table, key:onAdd.key, val:onAdd.val } )
    alloc  = onAdd.val
    roomId = onAdd.key
    @room.  onAlloc( alloc, roomId ) if @room?
    @book.  onAlloc( alloc, roomId ) if @book?
    @master.onAlloc( alloc, roomId ) if @master?
    return