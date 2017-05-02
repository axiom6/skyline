
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Util.jquery = require( 'jquery'             ) # Allows Pick cto be called outside of CommonJS
      Stream      = require( 'js/store/Stream'    )
      Firestore   = require( 'js/store/Firestore' )
      Data        = require( 'js/res/Data'        )
      Room        = require( 'js/res/Room'        )
      Home        = require( 'js/res/Home'        )
      Pict        = require( 'js/res/Pict'        )
      Res         = require( 'js/res/Res'         )
      Pay         = require( 'js/res/Pay'         )
      Book        = require( 'js/res/Book'        )
      Test        = require( 'js/res/Test'        )

      pict       = new Pict()
      stream     = new Stream( [] )
      store      = new Firestore(  stream, "skytest", Data.configSkytest )
      room       = new Room(       stream, store, Data )
      cust       = new Cust(       stream, store, Data )
      home       = new Home(       stream, store, room, pict )
      res        = new Res(        stream, store, room, Data )
      pay        = new Pay(        stream, store, room, res, home, Data )
      book       = new Book(       stream, store, room, res, pay,  pict, Data )
      test       = new Test(       stream, store, room, res, pay,  pict, book, Data )
      home.ready( book )
      test.doTest()

Guest.init()
