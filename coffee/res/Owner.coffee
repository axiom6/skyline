
class Owner

  module.exports = Owner

  @init = () ->

    Util.ready ->

      Stream   = require( 'js/store/Stream' )
      Fire     = require( 'js/store/Fire'   )
      Data     = require( 'js/res/Data'     )
      Room     = require( 'js/res/Room'     )
      Res      = require( 'js/res/Res'      )
      Master   = require( 'js/res/Master'   )

      stream   = new Stream( [] )
      store    = new Fire(   stream, "skytest", Data.configSkytest )
      room     = new Room(   stream, store, Data )
      res      = new Res(    stream, store, Data, room )
      master   = new Master( stream, store, Data, room, res )
      master.ready()

Owner.init()