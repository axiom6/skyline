
class Res

  module.exports = Res

  @init = () ->

    Util.ready ->

      Stream    = require( 'js/store/Stream'    )
      Firestore = require( 'js/store/Firestore' )
      Room      = require( 'js/res/Room'        )
      Cust      = require( 'js/res/Cust'        )
      Book      = require( 'js/res/Book'        )

      subjects = ["Book","Alloc","Debug"]
      stream   = new Stream( subjects )
      store    = new Firestore( stream, "skytest" )
      room     = new Room(      stream, store )
      cust     = new Cust(      stream, store )
      book     = new Book(      stream, store, room, cust )

      #room.open()     # -KeuSkDgdE8xc0ergdAB
      #room.insert()
      room.select()

      book.ready()

  @onDebug:( debug ) =>
    Util.log( "Res.onDebug()", debug )

Res.init()

#data    = new Data(      stream, store, room, cust, book )
# stream.subscribe( 'Debug', (debug) => Res.onDebug( debug ) )
# stream.publish(   "Debug", "Debug String" )