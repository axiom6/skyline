
class Owner

  module.exports = Owner

  @init = () ->

    Util.ready ->

      Stream   = require( 'js/store/Stream' )
      Fire     = require( 'js/store/Fire'   )
      Data     = require( 'js/res/Data'     )
      Res      = require( 'js/res/Res'      )
      Master   = require( 'js/res/Master'   )

      stream   = new Stream( [] )
      store    = new Fire(   stream, "skytest", Data.configSkytest )
      res      = new Res(    stream, store, Data, 'Owner' )
      master   = new Master( stream, store, Data, res )
      master.ready()

Owner.init()