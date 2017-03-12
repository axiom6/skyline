// Generated by CoffeeScript 1.12.2
(function() {
  var Room,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  Room = (function() {
    module.exports = Room;

    Room.Data = require('data/Room.json');

    function Room(stream, store) {
      this.stream = stream;
      this.store = store;
      this.west = bind(this.west, this);
      this.onDel = bind(this.onDel, this);
      this.onPut = bind(this.onPut, this);
      this.onAdd = bind(this.onAdd, this);
      this.del = bind(this.del, this);
      this.put = bind(this.put, this);
      this.get = bind(this.get, this);
      this.add = bind(this.add, this);
      this.select = bind(this.select, this);
      this.insert = bind(this.insert, this);
      this.drop = bind(this.drop, this);
      this.show = bind(this.show, this);
      this.make = bind(this.make, this);
      this.data = Room.Data;
      this.UIs = this.createUIs(this.data);
      this.subscribe();
    }

    Room.prototype.createUIs = function(data) {
      var UIs, key, room;
      UIs = {};
      for (key in data) {
        room = data[key];
        UIs[key] = {};
      }
      return UIs;
    };

    Room.prototype.doRoom = function() {
      this.make().then(this.insert()).then(this.select()).then(this.on()).then(this.add()).then(this.get()).then(this.put()).then(this.del());
    };

    Room.prototype.subscribe = function() {
      this.store.subscribe('Room', 'none', 'make', (function(_this) {
        return function(make) {
          Util.log('Room.make()', make);
          return _this.insert();
        };
      })(this));
      this.store.subscribe('Room', 'none', 'insert', (function(_this) {
        return function(insert) {
          Util.log('Room.insert()', insert);
          return _this.select();
        };
      })(this));
      this.store.subscribe('Room', 'none', 'select', (function(_this) {
        return function(select) {
          Util.log('Room.select()', select);
          _this.onAdd();
          _this.onPut();
          _this.onDel();
          return _this.add();
        };
      })(this));
      this.store.subscribe('Room', 'none', 'onAdd', (function(_this) {
        return function(onAdd) {
          return Util.log('Room.onAdd()', onAdd);
        };
      })(this));
      this.store.subscribe('Room', 'none', 'onPut', (function(_this) {
        return function(onPut) {
          return Util.log('Room.onPut()', onPut);
        };
      })(this));
      this.store.subscribe('Room', 'none', 'onDel', (function(_this) {
        return function(onDel) {
          return Util.log('Room.onDel()', onDel);
        };
      })(this));
      this.store.subscribe('Room', 'W', 'add', (function(_this) {
        return function(add) {
          Util.log('Room.add()', add);
          return _this.get();
        };
      })(this));
      this.store.subscribe('Room', 'S', 'get', (function(_this) {
        return function(get) {
          Util.log('Room.get()', get);
          return _this.put();
        };
      })(this));
      this.store.subscribe('Room', '7', 'put', (function(_this) {
        return function(put) {
          Util.log('Room.put()', put);
          return _this.del();
        };
      })(this));
      this.store.subscribe('Room', '8', 'del', (function(_this) {
        return function(del) {
          Util.log('Room.del()', del);
          return _this.show();
        };
      })(this));
      this.store.subscribe('Room', 'none', 'show', (function(_this) {
        return function(show) {
          return Util.log('Room.show()', show);
        };
      })(this));
      return this.store.subscribe('Room', 'none', 'drop', (function(_this) {
        return function(drop) {
          return Util.log('Room.drop()', drop);
        };
      })(this));
    };

    Room.prototype.make = function() {
      return this.store.make('Room');
    };

    Room.prototype.show = function() {
      return this.store.show('Room');
    };

    Room.prototype.drop = function() {
      return this.store.drop('Room');
    };

    Room.prototype.insert = function() {
      var key, ref, room;
      ref = Room.Data;
      for (key in ref) {
        if (!hasProp.call(ref, key)) continue;
        room = ref[key];
        Util.log('Room.Data', key, room);
      }
      return this.store.insert('Room', Room.Data);
    };

    Room.prototype.select = function() {
      return this.store.select('Room');
    };

    Room.prototype.add = function() {
      return this.store.add('Room', "W", this.west());
    };

    Room.prototype.get = function() {
      return this.store.get('Room', "S");
    };

    Room.prototype.put = function() {
      return this.store.put('Room', "7", this.west());
    };

    Room.prototype.del = function() {
      return this.store.del('Room', "8");
    };

    Room.prototype.onAdd = function() {
      return this.store.on('onAdd', 'Room');
    };

    Room.prototype.onPut = function() {
      return this.store.on('onPut', 'Room');
    };

    Room.prototype.onDel = function() {
      return this.store.on('onDel', 'Room');
    };

    Room.prototype.west = function() {
      return {
        "name": "West Skyline",
        "pet": 12,
        "spa": 0,
        "max": 4,
        "price": 0,
        "1": 135,
        "2": 135,
        "3": 145,
        "4": 155
      };
    };

    return Room;

  })();

}).call(this);
