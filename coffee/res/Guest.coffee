
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Util.jquery = require( 'jquery' ) # Allows Pick cto be called outside of CommonJS

      Stream  = require( 'js/store/Stream' )
      Fire    = require( 'js/store/Fire'   )
      #Memory = require( 'js/store/Memory' )
      Home    = require( 'js/res/Home'     )
      Pict    = require( 'public/js/Pict'  )
      Res     = require( 'js/res/Res'      )
      Pay     = require( 'js/res/Pay'      )
      Book    = require( 'js/res/Book'     )
      Test    = require( 'js/res/Test'     )

      pict   = new Pict()
      stream = new Stream( [] )
      store  = new Fire(   stream, "skytest", Data.configSkytest )
      #store = new Memory( stream, "skytest"  )
      res    = new Res(    stream, store, 'Guest' )
      home   = new Home(   stream, store, res, pict )
      pay    = new Pay(    stream, store, res, home )
      book   = new Book(   stream, store, res, pay, pict )
      test   = new Test(   stream, store, res, pay, pict, book )

      book.test = test
      home.ready( book )


Guest.init()
