
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Stream     = require( 'js/store/Stream'    )
      Firestore  = require( 'js/store/Firestore' )
      Data       = require( 'js/res/Data'        )
      Room       = require( 'js/res/Room'        )
      Cust       = require( 'js/res/Cust'        )
      Pict       = require( 'js/res/Pict'        )
      Res        = require( 'js/res/Res'         )
      Pay        = require( 'js/res/Pay'         )
      Book       = require( 'js/res/Book'        )

      stream     = new Stream( [] )
      store      = new Firestore(  stream, "skytest", Data.configSkytest )
      room       = new Room(       stream, store, Data )
      cust       = new Cust(       stream, store )
      pict       = new Pict(       stream, store, room, Data )
      res        = new Res(        stream, store, room, cust )
      pay        = new Pay(        stream, store, room, cust, res, Data )
      book       = new Book(       stream, store, room, cust, res, pay, pict, Data )

      book.ready()

Guest.init()
