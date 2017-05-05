// Generated by CoffeeScript 1.12.2
(function() {
  var Room,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  Room = (function() {
    module.exports = Room;

    Room.Rooms = require('data/room.json');

    Room.States = ["free", "mine", "depo", "book"];

    function Room(stream, store, Data) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.onAlloc = bind(this.onAlloc, this);
      this.initRooms = bind(this.initRooms, this);
      this.rooms = Room.Rooms;
      this.states = Room.States;
      this.roomUIs = this.createRoomUIs(this.rooms);
      this.initRooms();
    }

    Room.prototype.createRoomUIs = function(rooms) {
      var key, room, roomUI, roomUIs;
      roomUIs = {};
      for (key in rooms) {
        room = rooms[key];
        roomUIs[key] = {};
        roomUI = roomUIs[key];
        roomUI.$ = {};
        roomUI.name = room.name;
        roomUI.total = 0;
        roomUI.price = 0;
        roomUI.guests = 2;
        roomUI.pets = 0;
        roomUI.spa = room.spa;
        roomUI.change = 0;
        roomUI.days = {};
        roomUI.group = {};
      }
      return roomUIs;
    };

    Room.prototype.optSpa = function(roomId) {
      return this.rooms[roomId].spa === 'O';
    };

    Room.prototype.hasSpa = function(roomId) {
      return this.rooms[roomId].spa === 'O' || this.rooms[roomId].spa === 'Y';
    };

    Room.prototype.initRooms = function() {
      this.store.subscribe('Room', 'none', 'make', (function(_this) {
        return function(make) {
          _this.store.insert('Room', _this.rooms);
          return Util.noop(make);
        };
      })(this));
      return this.store.make('Room');
    };

    Room.prototype.dayBookedRm = function(room, date) {
      var day;
      day = room.days[date];
      if (day != null) {
        return day.status;
      } else {
        return 'free';
      }
    };

    Room.prototype.dayBookedUI = function(room, date) {
      var day;
      day = room.days[date];
      if (day != null) {
        return day.status;
      } else {
        return 'free';
      }
    };

    Room.prototype.onAlloc = function(alloc, roomId) {
      var day, obj, ref, room;
      room = this.rooms[roomId];
      ref = alloc.days;
      for (day in ref) {
        if (!hasProp.call(ref, day)) continue;
        obj = ref[day];
        room.days[day] = alloc.days[day];
      }
      this.store.put('Room', roomId, room);
    };

    return Room;

  })();

}).call(this);
