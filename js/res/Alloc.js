// Generated by CoffeeScript 1.12.2
(function() {
  var Alloc;

  Alloc = (function() {
    module.exports = Alloc;

    function Alloc(stream, store, Data, room, book, master) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.room = room != null ? room : null;
      this.book = book != null ? book : null;
      this.master = master != null ? master : null;
      this.subscribe();
      this.rooms = this.room.rooms;
    }

    Alloc.prototype.subscribe = function() {
      this.store.subscribe('Alloc', 'none', 'make', (function(_this) {
        return function(make) {
          return Util.noop('Alloc.make()', make);
        };
      })(this));
      this.store.subscribe('Alloc', 'none', 'onAdd', (function(_this) {
        return function(onAdd) {
          return _this.onAlloc(onAdd);
        };
      })(this));
      this.store.subscribe('Alloc', 'none', 'onPut', (function(_this) {
        return function(onPut) {
          return _this.onAlloc(onPut);
        };
      })(this));
      this.store.subscribe('Alloc', 'none', 'onDel', (function(_this) {
        return function(onDel) {
          return Util.noop('Alloc.onDel()', onDel);
        };
      })(this));
      this.store.make('Alloc');
      this.store.on('Alloc', 'onAdd');
      this.store.on('Alloc', 'onPut');
      return this.store.on('Alloc', 'onDel');
    };

    return Alloc;

  })();

}).call(this);
