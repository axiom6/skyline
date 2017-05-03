
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Util.jquery = require( 'jquery' ) # Allows Pick cto be called outside of CommonJS

      Stream = require( 'js/store/Stream' )
      Fire   = require( 'js/store/Fire  ' )
      Data   = require( 'js/res/Data'     )
      Room   = require( 'js/res/Room'     )
      Home   = require( 'js/res/Home'     )
      Pict   = require( 'js/res/Pict'     )
      Res    = require( 'js/res/Res'      )
      Pay    = require( 'js/res/Pay'      )
      Book   = require( 'js/res/Book'     )
      Test   = require( 'js/res/Test'     )

      pict   = new Pict()
      stream = new Stream( [] )
      store  = new Fire( stream, "skytest", Data.configSkytest )
      room   = new Room( stream, store, Data )
      home   = new Home( stream, store, Data, room, pict )
      res    = new Res(  stream, store, Data, room )
      pay    = new Pay(  stream, store, Data, room, res, home )
      book   = new Book( stream, store, Data, room, res, pay,  pict )
      test   = new Test( stream, store, Data, room, res, pay,  pict, book )
      home.ready( book )
      test.doTest()

Guest.init()
