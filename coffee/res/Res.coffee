
class Res

  module.exports = Res

  @init = () ->

    Util.ready ->

      Stream = require( 'js/store/Stream' )
      Store  = require( 'js/store/Store'  )
      Room   = require( 'js/res/Room'     )
      Cust   = require( 'js/res/Cust'     )
      Book   = require( 'js/res/Book'     )

      subjects = ["Book","Alloc"]
      stream   = new Stream( subjects )
      store    = new Store( stream, "skytest", "Firebase")
      room     = new Room()
      cust     = new Cust()
      book     = new Book( stream, store, room, cust )

      book.ready()

Res.init()