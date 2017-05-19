// Generated by CoffeeScript 1.12.2
(function() {
  var Res,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  Res = (function() {
    module.exports = Res;

    Res.Rooms = require('data/room.json');

    Res.Resvs = require('data/res.json');

    Res.Days = require('data/days.json');

    Res.States = ["free", "mine", "depo", "book"];

    function Res(stream, store, Data, appName) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.appName = appName;
      this.insertRooms = bind(this.insertRooms, this);
      this.onDays = bind(this.onDays, this);
      this.onResv = bind(this.onResv, this);
      this.onResId = bind(this.onResId, this);
      this.rooms = Res.Rooms;
      this.states = Res.States;
      this.book = null;
      this.master = null;
      this.days = null;
      this.beg = this.Data.toDateStr(this.Data.begDay);
      this.end = this.Data.advanceDate(this.beg, this.Data.numDays);
      if (this.Data.insertNewTables) {
        this.insertNewTables();
      }
      if (!this.Data.insertNewTables && this.appName === 'Guest') {
        this.dateRange();
      }
    }

    Res.prototype.dateRange = function(onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.beg = this.Data.toDateStr(this.Data.begDay);
      this.end = this.Data.advanceDate(this.beg, this.Data.numDays - 1);
      this.store.subscribe('Days', 'none', 'range', (function(_this) {
        return function(days) {
          _this.days = days;
          if (onComplete != null) {
            return onComplete();
          }
        };
      })(this));
      this.store.range('Days', this.beg, this.end);
    };

    Res.prototype.insertNewTables = function() {
      this.insertRooms(Res.Rooms);
      this.insertRevs(Res.Resvs);
      return this.insertDays(Res.Resvs);
    };

    Res.prototype.dayBooked = function(roomId, date) {
      var day, entry;
      day = this.days != null ? this.days[date] : void 0;
      entry = (day != null) && day[roomId] ? day[roomId] : null;
      if (entry != null) {
        return entry.status;
      } else {
        return 'free';
      }
    };

    Res.prototype.createRoomUIs = function(rooms) {
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
        roomUI.reason = 'No Changes';
        roomUI.days = {};
        roomUI.group = {};
      }
      return roomUIs;
    };

    Res.prototype.optSpa = function(roomId) {
      return this.rooms[roomId].spa === 'O';
    };

    Res.prototype.hasSpa = function(roomId) {
      return this.rooms[roomId].spa === 'O' || this.rooms[roomId].spa === 'Y';
    };

    Res.prototype.createRoomResv = function(status, method, roomUIs) {
      var day, obj, ref, resv, roomId, roomUI;
      resv = {};
      resv.resId = this.Data.genResId(roomUIs);
      resv.totals = 0;
      resv.paid = 0;
      resv.balance = 0;
      resv.status = status;
      resv.method = method;
      resv.booked = this.Data.today();
      resv.arrive = resv.resId.substr(0, 6);
      resv.rooms = {};
      for (roomId in roomUIs) {
        if (!hasProp.call(roomUIs, roomId)) continue;
        roomUI = roomUIs[roomId];
        if (!(!Util.isObjEmpty(roomUI.days))) {
          continue;
        }
        resv.rooms[roomId] = this.toResvRoom(roomUI);
        ref = roomUI.days;
        for (day in ref) {
          if (!hasProp.call(ref, day)) continue;
          obj = ref[day];
          if (day.status === 'mine') {
            day.status = status;
          }
          if (day < resv.arrive) {
            resv.arrive = day;
          }
        }
      }
      resv.payments = {};
      resv.cust = {};
      return resv;
    };

    Res.prototype.toResvRoom = function(roomUI) {
      var room;
      room = {};
      room.name = roomUI.name;
      room.total = roomUI.total;
      room.price = roomUI.price;
      room.guests = roomUI.guests;
      room.pets = roomUI.pets;
      room.spa = roomUI.spa;
      room.change = roomUI.change;
      room.reason = roomUI.reason;
      room.days = roomUI.days;
      room.nights = Util.keys(roomUI.days).length;
      return room;
    };

    Res.prototype.allocRooms = function(resv) {
      var day, dayId, ref, ref1, results, room, roomId;
      ref = resv.rooms;
      results = [];
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        ref1 = room.days;
        for (dayId in ref1) {
          if (!hasProp.call(ref1, dayId)) continue;
          day = ref1[dayId];
          this.setDayRoom(day, resv.status, resv.resId);
        }
        delete room.group;
        results.push(this.allocRoom(roomId, room.days));
      }
      return results;
    };

    Res.prototype.allocRoom = function(roomId, days) {
      if (this.book != null) {
        this.book.onAlloc(roomId, days);
      }
      if (this.master != null) {
        return this.master.onAlloc(roomId, days);
      }
    };

    Res.prototype.onResId = function(onOp, doResv, resId) {
      return this.store.on('Res', onOp, resId, (function(_this) {
        return function(resv) {
          return doResv(resv);
        };
      })(this));
    };

    Res.prototype.onResv = function(onOp, doResv) {
      return this.store.on('Res', onOp, 'none', (function(_this) {
        return function(resv) {
          return doResv(resv);
        };
      })(this));
    };

    Res.prototype.onDays = function(onOp, doDay) {
      return this.store.on('Days', onOp, 'none', (function(_this) {
        return function(day) {
          return doDay(day);
        };
      })(this));
    };

    Res.prototype.insertRooms = function(rooms) {
      this.store.subscribe('Room', 'make', 'none', (function(_this) {
        return function(make) {
          _this.store.insert('Room', rooms);
          return Util.noop(make);
        };
      })(this));
      this.store.make('Room');
    };

    Res.prototype.insertRevs = function(resvs) {
      var resId, resv;
      for (resId in resvs) {
        if (!hasProp.call(resvs, resId)) continue;
        resv = resvs[resId];
        this.allocRooms(resv);
      }
      this.store.subscribe('Res', 'make', 'none', (function(_this) {
        return function() {
          return _this.store.insert('Res', resvs);
        };
      })(this));
      this.store.make('Res');
    };

    Res.prototype.insertDays = function(resvs) {
      var day, dayId, ref;
      this.days = this.createDaysFromResvs(resvs, {});
      ref = this.days;
      for (dayId in ref) {
        if (!hasProp.call(ref, dayId)) continue;
        day = ref[dayId];
        this.store.add('Days', dayId, day);
      }
    };

    Res.prototype.createDaysFromResvs = function(resvs, days) {
      var resv, resvId;
      for (resvId in resvs) {
        if (!hasProp.call(resvs, resvId)) continue;
        resv = resvs[resvId];
        days = this.createDaysFromResv(resv, days);
      }
      return days;
    };

    Res.prototype.createDaysFromResv = function(resv, days) {
      var dayId, dayRoom, rday, ref, ref1, room, roomId;
      ref = resv.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        ref1 = room.days;
        for (dayId in ref1) {
          if (!hasProp.call(ref1, dayId)) continue;
          rday = ref1[dayId];
          dayRoom = this.createDayRoom(days, dayId, roomId);
          this.setDayRoom(dayRoom, rday.status, rday.resId);
        }
      }
      return days;
    };

    Res.prototype.createDayRoom = function(days, dayId, roomIdA) {
      var roomId;
      roomId = roomIdA.toString();
      if (days[dayId] == null) {
        days[dayId] = {};
      }
      days[dayId][roomId] = {};
      return days[dayId][roomId];
    };

    Res.prototype.createCust = function(first, last, phone, email, source) {
      var cust;
      cust = {};
      cust.custId = this.Data.genCustId(phone);
      cust.first = first;
      cust.last = last;
      cust.phone = phone;
      cust.email = email;
      cust.source = source;
      return cust;
    };

    Res.prototype.createPayment = function(amount, method, last4, purpose) {
      var payment;
      payment = {};
      payment.amount = amount;
      payment.date = this.Data.today();
      payment.method = method;
      payment["with"] = last4;
      payment.purpose = purpose;
      payment.cc = '';
      payment.exp = '';
      payment.cvc = '';
      return payment;
    };

    Res.prototype.setResvStatus = function(resv, post, purpose) {
      if (post === 'post') {
        if (purpose === 'PayInFull' || purpose === 'PayOffDeposit') {
          resv.status = 'book';
        }
        if (purpose === 'Deposit') {
          resv.status = 'depo';
        }
      } else if (post === 'deny') {
        resv.status = 'free';
      }
      if (!Util.inArray(['book', 'depo', 'free'], resv.status)) {
        Util.error('Pay.setResStatus() unknown status ', resv.status);
        resv.status = 'free';
      }
      return resv.status;
    };

    Res.prototype.postResv = function(resv, post, totals, amount, method, last4, purpose) {
      var payId, status;
      status = this.setResvStatus(resv, post, purpose);
      if (status === 'book' || status === 'depo') {
        payId = this.Data.genPaymentId(resv.resId, resv.payments);
        resv.payments[payId] = this.createPayment(amount, method, last4, purpose);
        resv.totals = totals;
        resv.paid += amount;
        resv.balance = totals - resv.paid;
        this.allocRooms(resv);
        this.store.add('Res', resv.resId, resv);
        return this.days = this.mergePostDays(resv, this.days);
      }
    };

    Res.prototype.mergePostDays = function(resv, allDays) {
      var dayRoom, newDay, newDayId, newDays, room, roomId;
      newDays = this.createDaysFromResv(resv, {});
      for (newDayId in newDays) {
        if (!hasProp.call(newDays, newDayId)) continue;
        newDay = newDays[newDayId];
        for (roomId in newDay) {
          if (!hasProp.call(newDay, roomId)) continue;
          room = newDay[roomId];
          dayRoom = this.createDayRoom(allDays, newDayId, roomId);
          this.setDayRoom(dayRoom, room.status, room.resId);
          this.store.put('Days', newDayId + '/' + roomId, dayRoom);
        }
      }
      return allDays;
    };

    Res.prototype.setDayRoom = function(dayRoom, status, resId) {
      dayRoom.status = status;
      return dayRoom.resId = resId;
    };

    return Res;

  })();

}).call(this);
