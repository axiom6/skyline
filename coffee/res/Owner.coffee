
class Owner

  module.exports = Owner

  @init = () ->

    Util.ready ->

      Stream    = require( 'js/store/Stream'    )
      Firestore = require( 'js/store/Firestore' )
      Data      = require( 'js/res/Data'        )
      Room      = require( 'js/res/Room'        )
      Cust      = require( 'js/res/Cust'        )
      Res       = require( 'js/res/Res'         )
      Master    = require( 'js/res/Master'      )
      Alloc     = require( 'js/res/Alloc'       )

      stream   = new Stream( [] )
      store    = new Firestore( stream, "skytest", Data.configSkytest )
      room     = new Room(      stream, store, Data )
      cust     = new Cust(      stream, store )
      res      = new Res(       stream, store, room, cust )
      master   = new Master(    stream, store, room, cust, res )
      alloc    = new Alloc(     stream, store, room, cust, res, master )
      master.ready()

Owner.init()