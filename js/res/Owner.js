// Generated by CoffeeScript 1.12.2
(function() {
  var Owner;

  Owner = (function() {
    function Owner() {}

    module.exports = Owner;

    Owner.init = function() {
      return Util.ready(function() {
        var Data, Fire, Master, Memory, Res, Stream, config, master, res, store, stream;
        Stream = require('js/store/Stream');
        Fire = require('js/store/Fire');
        Memory = require('js/store/Memory');
        Data = require('js/res/Data');
        Res = require('js/res/Res');
        Master = require('js/res/Master');
        config = Util.arg === 'skytest' ? Data.configSkytest : Data.configSkyline;
        stream = new Stream([]);
        store = new Fire(stream, Util.arg, config);
        res = new Res(stream, store, 'Owner');
        master = new Master(stream, store, res);
        return master.ready();
      });
    };

    return Owner;

  })();

  Owner.init();

}).call(this);
