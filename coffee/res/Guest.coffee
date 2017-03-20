
class Guest

  module.exports = Guest

  @init = () ->

    Util.ready ->

      Stream    = require( 'js/store/Stream'    )
      Firestore = require( 'js/store/Firestore' )
      Data      = require( 'js/res/Data'        )
      Room      = require( 'js/res/Room'        )
      Cust      = require( 'js/res/Cust'        )
      Book      = require( 'js/res/Book'        )
      Master    = require( 'js/res/Master'      )

      stream   = new Stream( [] )
      store    = new Firestore( stream, "skytest", Data.configSkytest )
      room     = new Room(      stream, store )
      cust     = new Cust(      stream, store )
      book     = new Book(      stream, store, room, cust )
      master   = new Master(    stream, store, room, cust, book )

      book.  ready()
      master.ready()

Guest.init()
