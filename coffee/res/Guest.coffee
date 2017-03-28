
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Stream     = require( 'js/store/Stream'    )
      Firestore  = require( 'js/store/Firestore' )
      Data       = require( 'js/res/Data'        )
      Room       = require( 'js/res/Room'        )
      Cust       = require( 'js/res/Cust'        )
      Res        = require( 'js/res/Res'         )
      Book       = require( 'js/res/Book'        )
      Pay        = require( 'js/res/Pay'         )
      #Master     = require( 'js/res/Master'     )
      #Alloc      = require( 'js/res/Alloc'      )

      stream     = new Stream( [] )
      store      = new Firestore(  stream, "skytest", Data.configSkytest )
      room       = new Room(       stream, store, Data )
      cust       = new Cust(       stream, store )
      res        = new Res(        stream, store, room, cust )
      book       = new Book(       stream, store, room, cust, res )
      pay        = new Pay(        stream, store, room, cust, res )
      #master    = new Master(     stream, store, room, cust, res )
      #alloc     = new Alloc(      stream, store, room, cust, res, master, book )
      book.      ready()
      pay.       ready()
      #master.   ready()
      #Util.noop( alloc )

Guest.init()
