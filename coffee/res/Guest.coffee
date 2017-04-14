
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Stream     = require( 'js/store/Stream'    )
      Firestore  = require( 'js/store/Firestore' )
      Data       = require( 'js/res/Data'        )
      Room       = require( 'js/res/Room'        )
      Cust       = require( 'js/res/Cust'        )
      Home       = require( 'js/res/Home'        )
      Pict       = require( 'js/res/Pict'        )
      Res        = require( 'js/res/Res'         )
      Pay        = require( 'js/res/Pay'         )
      Book       = require( 'js/res/Book'        )

      pict       = new Pict()
      stream     = new Stream( [] )
      store      = new Firestore(  stream, "skytest", Data.configSkytest )
      room       = new Room(       stream, store, Data )
      cust       = new Cust(       stream, store )
      home       = new Home(       stream, store, room, pict )
      res        = new Res(        stream, store, room, Data )
      pay        = new Pay(        stream, store, room, cust, res, Data )
      book       = new Book(       stream, store, room, cust, res, pay, pict, Data )
      home.ready( book )

Guest.init()
