
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Stream  = require( 'js/store/Stream' )
      #Fire   = require( 'js/store/Fire'   )
      Memory  = require( 'js/store/Memory' )
      Data    = require( 'js/res/Data'     )
      Home    = require( 'js/res/Home'     )
      Res     = require( 'js/res/Res'      )
      Pay     = require( 'js/res/Pay'      )
      Book    = require( 'js/res/Book'     )
      Test    = require( 'js/res/Test'     )

      pict   = new window.Pict()
      stream = new Stream( [] )
      #tore  = new Fire(   stream, "skyline", Data.configSkyline )
      store  = new Memory( stream, "skyriver"  )
      res    = new Res(    stream, store, 'Guest' )
      home   = new Home(   stream, store, res, pict )
      pay    = new Pay(    stream, store, res, home )
      book   = new Book(   stream, store, res, pay, pict )
      test   = new Test(   stream, store, res, pay, pict, book )

      book.test = test
      home.ready( book )


Guest.init()
