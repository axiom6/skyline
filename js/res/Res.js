// Generated by CoffeeScript 1.12.2
(function() {
  var Res,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  Res = (function() {
    module.exports = Res;

    Res.Resvs = require('data/res.json');

    Res.Days = require('data/days.json');

    function Res(stream, store, Data, room1) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.room = room1;
      this.subscribeToDays = bind(this.subscribeToDays, this);
      this.subscribeToResId = bind(this.subscribeToResId, this);
      this.days = {};
      this.book = null;
      this.master = null;
      if (this.Data.testing) {
        this.insertRevs(Res.Resvs);
      }
      if (this.Data.testing) {
        this.insertDays(Res.Resvs);
      }
    }

    Res.prototype.dayBooked = function(roomId, date) {
      var day, entry;
      day = Res.Days[date];
      entry = (day != null) && day[roomId] ? day[roomId] : null;
      if (entry != null) {
        return entry.status;
      } else {
        return 'free';
      }
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
      resv.arrive = resv.resId.substr(1, 8);
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
      this.subscribeToResId(resv.resId);
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

    Res.prototype.updateRooms = function(resv) {
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
          day.status = resv.status;
          day.resId = resv.resId;
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

    Res.prototype.subscribeToResId = function(resId) {
      this.store.subscribe('Res', resId, 'onAdd', (function(_this) {
        return function(onAdd) {
          return Util.log('Res.subscribeToResId onAdd', resId, onAdd);
        };
      })(this));
      this.store.subscribe('Res', resId, 'onPut', (function(_this) {
        return function(onPut) {
          return Util.log('Res.subscribeToResId onPut', resId, onPut);
        };
      })(this));
      this.store.subscribe('Res', resId, 'onDel', (function(_this) {
        return function(onDel) {
          return Util.log('Res.subscribeToResId onDel', resId, onDel);
        };
      })(this));
      this.store.on('Res', 'onAdd', resId);
      this.store.on('Res', 'onPut', resId);
      return this.store.on('Res', 'onDel', resId);
    };

    Res.prototype.subscribeToDays = function() {
      this.store.subscribe('Days', 'none', 'onAdd', (function(_this) {
        return function(onAdd) {
          return Util.log('Res.subscribeToDays onAdd', onAdd);
        };
      })(this));
      this.store.subscribe('Days', 'none', 'onPut', (function(_this) {
        return function(onPut) {
          return Util.log('Res.subscribeToDays onPut', onPut);
        };
      })(this));
      this.store.subscribe('Days', 'none', 'onDel', (function(_this) {
        return function(onDel) {
          return Util.log('Res.subscribeToDays onDel', onDel);
        };
      })(this));
      this.store.on('Days', 'onAdd');
      this.store.on('Days', 'onPut');
      return this.store.on('Days', 'onDel');
    };

    Res.prototype.insertRevs = function(resvs) {
      var resId, resv;
      this.store.subscribe('Res', 'none', 'make', (function(_this) {
        return function() {
          return _this.store.insert('Res', resvs);
        };
      })(this));
      this.store.make('Res');
      for (resId in resvs) {
        if (!hasProp.call(resvs, resId)) continue;
        resv = resvs[resId];
        this.updateRooms(resv);
      }
    };

    Res.prototype.insertDays = function(resvs) {
      var day, dayId, rday, ref, ref1, resv, resvId, room, roomId;
      for (resvId in resvs) {
        if (!hasProp.call(resvs, resvId)) continue;
        resv = resvs[resvId];
        ref = resv.rooms;
        for (roomId in ref) {
          if (!hasProp.call(ref, roomId)) continue;
          room = ref[roomId];
          if (!Util.inArray(['1', '2', '3', '4', '5', '6', '7', '8', 'N', 'S'], roomId)) {
            Util.error('Res.insertDays', roomId);
          }
          ref1 = room.days;
          for (dayId in ref1) {
            if (!hasProp.call(ref1, dayId)) continue;
            rday = ref1[dayId];
            day = this.createDay(this.days, dayId, roomId);
            day.status = rday.status;
            day.resId = rday.resId;
          }
        }
      }
      Util.log('Res.insertDaysResvs() days', Res.Days);
      this.store.subscribe('Days', 'none', 'make', (function(_this) {
        return function() {
          return _this.store.insert('Days', Res.Days);
        };
      })(this));
      this.store.make('Days');
      this.subscribeToDays();
    };

    Res.xdays = {
      x170709: {
        r1: {
          status: "book",
          resId: 1707091
        }
      },
      x170710: {
        r1: {
          status: "book",
          resId: 1707091
        },
        r2: {
          status: "depo",
          resId: 1707102
        }
      },
      x170711: {
        r2: {
          status: "depo",
          resId: 1707102
        },
        r3: {
          status: "book",
          resId: 1707113
        }
      },
      x170712: {
        r3: {
          status: "book",
          resId: 1707113
        },
        r4: {
          status: "book",
          resId: 1707124
        }
      },
      x170713: {
        r4: {
          status: "book",
          resId: 1707124
        }
      },
      x170714: {
        r5: {
          status: "depo",
          resId: 1707145
        }
      },
      x170715: {
        r5: {
          status: "depo",
          resId: 1707145
        },
        r6: {
          status: "book",
          resId: 1707156
        }
      },
      x170716: {
        r6: {
          status: "book",
          resId: 1707156
        },
        r7: {
          status: "book",
          resId: 1707167
        }
      },
      x170717: {
        r7: {
          status: "book",
          resId: 1707167
        },
        r8: {
          status: "book",
          resId: 1707178
        }
      },
      x170718: {
        r8: {
          status: "book",
          resId: 1707178
        },
        rN: {
          status: "book",
          resId: 1707189
        }
      },
      x170719: {
        rN: {
          status: "book",
          resId: 1707189
        },
        rS: {
          status: "book",
          resId: 1707190
        }
      },
      x170720: {
        rS: {
          status: "book",
          resId: 1707190
        }
      }
    };

    Res.prototype.createDay = function(days, dayId, roomId) {
      var dayd;
      if (days == null) {
        Util.log('Res.createDay() days null ');
      }
      dayd = days[dayId];
      if (dayd == null) {
        dayd = {};
        days[dayId] = dayd;
      }
      dayd[roomId] = {};
      return dayd[roomId];
    };

    Res.prototype.makeAllTables = function() {
      this.store.make('Res');
      this.store.make('Room');
      this.store.make('Days');
      this.store.make('Payment');
      return this.store.make('Cust');
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
    };

    Res.prototype.postResv = function(resv, post, totals, amount, method, last4, purpose) {
      var payId;
      this.setResvStatus(resv, post, purpose);
      payId = this.Data.genPaymentId(resv.resId, resv.payments);
      resv.payments[payId] = this.createPayment(amount, method, last4, purpose);
      resv.totals = totals;
      resv.paid += amount;
      resv.balance = totals - resv.paid;
      this.updateRooms(resv);
      if (status === 'post') {
        this.store.add('Res', resv.resId, resv);
        this.postDays(resv);
      }
      return Util.log('Res.postResv()', resv);
    };

    Res.prototype.postDays = function(resv) {
      var dayId, dayd, dayr, ref, results, room, roomId;
      ref = resv.rooms;
      results = [];
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        results.push((function() {
          var ref1, results1;
          ref1 = room.days;
          results1 = [];
          for (dayId in ref1) {
            if (!hasProp.call(ref1, dayId)) continue;
            dayr = ref1[dayId];
            dayd = {};
            dayd.status = dayr.status;
            dayd.resId = dayr.resId;
            results1.push(this.store.add('Days/' + dayId, roomId, dayd));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    return Res;

  })();

}).call(this);
