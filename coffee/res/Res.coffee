
class Res

  module.exports = Res

  @init = () ->

    Util.ready ->

      Stream    = require( 'js/store/Stream'    )
      Firestore = require( 'js/store/Firestore' )
      Room      = require( 'js/res/Room'        )
      Cust      = require( 'js/res/Cust'        )
      Book      = require( 'js/res/Book'        )
      Data      = require( 'js/res/Data'        )


      subjects = ["Book","Alloc","Debug"]
      stream   = new Stream( subjects )
      store    = new Firestore( stream, "skytest", Data.configSkytest )
      room     = new Room(      stream, store )
      cust     = new Cust(      stream, store )
      book     = new Book(      stream, store, room, cust )
      data     = new Data(      stream, store, room, cust, book )

      data.doRoom()
      book.ready()

Res.init()
