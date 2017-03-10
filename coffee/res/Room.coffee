
class Room

  module.exports = Room
  Room.Data      = require( 'data/Room.json' )

  constructor:( @stream, @store ) ->
    @subscribe()

  subscribe:() ->
    @store.subscribe( 'Room', 'none', 'open',   (open)   => Util.log( 'Room.open()',   open   ) )
    @store.subscribe( 'Room', 'none', 'insert', (insert) => Util.log( 'Room.insert()', insert ) )
    @store.subscribe( 'Room', 'none', 'select', (select) => Util.log( 'Room.select()', select ) )

  open:() ->
    @store.open( 'Room' )
    return

  insert:() ->
    @store.insert( 'Room', Room.Data )
    return

  select:() ->
    @store.select( 'Room' )
    return