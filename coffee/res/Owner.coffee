
class Owner

  module.exports = Owner

  @init = () ->

    Util.ready ->

      Stream    = require( 'js/store/Stream'    )
      Firestore = require( 'js/store/Firestore' )
      Data      = require( 'js/res/Data'        )
      Room      = require( 'js/res/Room'        )
      Cust      = require( 'js/res/Cust'        )
      Master    = require( 'js/res/Master'      )
      Alloc     = require( 'js/res/MastAllocer' )

      stream   = new Stream( [] )
      store    = new Firestore( stream, "skytest", Data.configSkytest )
      room     = new Room(      stream, store )
      cust     = new Cust(      stream, store )
      master   = new Master(    stream, store, room, cust )
      alloc    = new Alloc(     stream, store, room, cust, master )
      master.ready()

Owner.init()