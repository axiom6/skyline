
class Owner

  module.exports = Owner

  @init = () ->

    Util.ready ->

      Stream   = require( 'js/store/Stream' )
      Fire     = require( 'js/store/Fire'   )
      Memory   = require( 'js/store/Memory' )
      Data     = require( 'js/res/Data'     )
      Res      = require( 'js/res/Res'      )
      Master   = require( 'js/res/Master'   )

      config   = if  Util.arg is 'skytest' then Data.configSkytest else Data.configSkyline
      stream   = new Stream( [] )
      store    = new Fire(   stream, Util.arg ,config )
      #tore    = new Memory( stream, Util.arg         )
      res      = new Res(    stream, store, 'Owner'   )
      master   = new Master( stream, store, res       )
      master.ready()

Owner.init()