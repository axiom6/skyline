
class Owner

  module.exports = Owner

  @init = () ->

    Util.ready ->

      Stream   = require( 'js/store/Stream'  )
      #Fire    = require( 'js/store/Fire'    )
      Memory   = require( 'js/store/Memory'  )
      Data     = require( 'js/res/Data'      )
      Res      = require( 'js/res/Res'       )
      Pay      = require( 'js/res/Pay'       )
      Master   = require( 'js/res/Master'    )

      stream   = new Stream( [] )
      #store   = new Fire(   stream, "skytest", Data.configSkytest )
      store    = new Memory( stream, "skytest" )
      store.justMemory = true
      res      = new Res(    stream, store, Data, 'Owner' )
      res.insertNewTables() if store.justMemory          # Populate Memory
      pay      = new Pay(    stream, store, Data, res )  # Pay is used to lookup confirmations
      master   = new Master( stream, store, Data, res, pay )
      master.ready()

Owner.init()