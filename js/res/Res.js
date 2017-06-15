// Generated by CoffeeScript 1.12.2
(function() {
  var $, Res,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Res = (function() {
    module.exports = Res;

    Res.Rooms = require('data/room.json');

    Res.Sets = ['full', 'book', 'resv', 'chan'];

    function Res(stream, store, Data1, appName) {
      this.stream = stream;
      this.store = store;
      this.Data = Data1;
      this.appName = appName;
      this.makeInput = bind(this.makeInput, this);
      this.makeSelect = bind(this.makeSelect, this);
      this.select = bind(this.select, this);
      this.insert = bind(this.insert, this);
      this.onDay = bind(this.onDay, this);
      this.onRes = bind(this.onRes, this);
      this.onResId = bind(this.onResId, this);
      this.rooms = Res.Rooms;
      this.roomKeys = Util.keys(this.rooms);
      this.book = null;
      this.master = null;
      this.days = {};
      this.resvs = {};
      if (this.appName === 'Guest') {
        this.dateRange(this.Data.beg, this.Data.end);
      }
    }

    Res.prototype.populateMemory = function() {
      this.onRes('add', (function(_this) {
        return function(resv) {
          return Util.noop('onRes', resv);
        };
      })(this));
      if (this.store.justMemory) {
        this.onDay('put', (function(_this) {
          return function(days) {
            return Util.noop('onDay', days);
          };
        })(this));
      }
      return this.makeTables();
    };

    Res.prototype.dateRange = function(beg, end, onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe('Day', 'range', 'none', (function(_this) {
        return function(days) {
          _this.days = days;
          if (onComplete != null) {
            return onComplete();
          }
        };
      })(this));
      this.store.range('Day', beg + '1', end + 'S');
    };

    Res.prototype.selectAllDays = function(onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe('Day', 'select', 'none', (function(_this) {
        return function(days) {
          _this.days = days;
          if (onComplete != null) {
            return onComplete();
          }
        };
      })(this));
      return this.store.select('Day');
    };

    Res.prototype.selectAllResvs = function(onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe('Res', 'select', 'none', (function(_this) {
        return function(resvs) {
          _this.resvs = resvs;
          if (onComplete != null) {
            return onComplete();
          }
        };
      })(this));
      return this.store.select('Res');
    };

    Res.prototype.roomUI = function(rooms) {
      var key, room;
      for (key in rooms) {
        if (!hasProp.call(rooms, key)) continue;
        room = rooms[key];
        room.$ = {};
        room = this.populateRoom(room, {}, 0, 0, 2, 0);
      }
    };

    Res.prototype.populateRoom = function(room, days, total, price, guests, pets) {
      room.days = days;
      room.total = total;
      room.price = price;
      room.guests = guests;
      room.pets = pets;
      room.change = 0;
      room.reason = 'No Changes';
      return room;
    };

    Res.prototype.status = function(date, roomId) {
      var day, dayId;
      dayId = this.Data.dayId(date, roomId);
      day = this.days[dayId];
      if (day != null) {
        return day.status;
      } else {
        return 'free';
      }
    };

    Res.prototype.day = function(date, roomId) {
      var day, dayId;
      dayId = this.Data.dayId(date, roomId);
      day = this.days[dayId];
      if (day != null) {
        return day;
      } else {
        return this.setDay({}, 'free', 'none');
      }
    };

    Res.prototype.dayIds = function(arrive, stayto, roomId) {
      var depart, i, ids, j, nights, ref;
      depart = Data.advanceDate(stayto, 1);
      nights = this.Data.nights(arrive, depart);
      ids = [];
      for (i = j = 0, ref = nights; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        ids.push(this.Data.dayId(this.Data.advanceDate(arrive, i), roomId));
      }
      return ids;
    };

    Res.prototype.resIds = function(arrive, stayto, roomId) {
      var dayId, depart, i, ids, j, nights, ref;
      depart = this.Data.advanceDate(stayto, 1);
      nights = this.Data.nights(arrive, depart);
      ids = [];
      for (i = j = 0, ref = nights; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        dayId = this.Data.dayId(this.Data.advanceDate(arrive, i), roomId);
        if ((this.days[dayId] != null) && !Util.inArray(ids, this.days[dayId].resId)) {
          ids.push(this.days[dayId].resId);
        }
      }
      return ids;
    };

    Res.prototype.resvRange = function(beg, end) {
      var j, k, len, len1, ref, resId, resIds, resvs, roomId;
      resvs = {};
      resIds = [];
      ref = this.roomKeys;
      for (j = 0, len = ref.length; j < len; j++) {
        roomId = ref[j];
        resIds.push(this.resIds(beg, end, roomId));
      }
      for (k = 0, len1 = resIds.length; k < len1; k++) {
        resId = resIds[k];
        if (this.resvs[resId] != null) {
          resvs[resId] = this.resvs[resId];
        }
      }
      return resvs;
    };

    Res.prototype.allocDays = function(days) {
      if (this.book != null) {
        this.book.allocDays(days);
      }
      if (this.master != null) {
        this.master.allocDays(days);
      }
    };

    Res.prototype.updateResvs = function(newResvs) {
      var resId, resv;
      for (resId in newResvs) {
        if (!hasProp.call(newResvs, resId)) continue;
        resv = newResvs[resId];
        this.resvs[resId] = resv;
        this.postResv(resv);
      }
      return this.resvs;
    };

    Res.prototype.updateDaysFromResv = function(resv) {
      var day, dayId, days, i, j, ref;
      days = {};
      for (i = j = 0, ref = resv.nights; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        dayId = this.Data.dayId(this.Data.advanceDate(resv.arrive, i), resv.roomId);
        days[dayId] = this.setDay({}, resv.status, resv.resId);
      }
      this.allocDays(days);
      for (dayId in days) {
        day = days[dayId];
        this.store.add('Day', dayId, day);
        this.days[dayId] = day;
      }
    };

    Res.prototype.calcPrice = function(roomId, guests, pets) {
      return this.rooms[roomId][guests] + pets * this.Data.petPrice;
    };

    Res.prototype.spaOptOut = function(roomId, isSpaOptOut) {
      if (isSpaOptOut == null) {
        isSpaOptOut = true;
      }
      if (this.rooms[roomId].spa === 'O' && isSpaOptOut) {
        return Data.spaOptOut;
      } else {
        return 0;
      }
    };

    Res.prototype.genDates = function(arrive, nights) {
      var date, dates, i, j, ref;
      dates = {};
      for (i = j = 0, ref = nights; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        date = this.Data.advanceDate(arrive, i);
        dates[date] = "";
      }
      return dates;
    };

    Res.prototype.createResvSkyline = function(arrive, depart, roomId, last, status, guests, pets, spa, cust, payments) {
      var booked, nights, price, total;
      if (spa == null) {
        spa = false;
      }
      if (cust == null) {
        cust = {};
      }
      if (payments == null) {
        payments = {};
      }
      booked = this.Data.today();
      price = this.rooms[roomId][guests] + pets * this.Data.petPrice;
      nights = this.Data.nights(arrive, depart);
      total = price * nights;
      return this.createResv(arrive, depart, booked, roomId, last, status, guests, pets, 'Skyline', total, spa, cust, payments);
    };

    Res.prototype.createResvBooking = function(arrive, depart, booked, roomId, last, status, guests, total) {
      var pets;
      total = total === 0 ? this.rooms[roomId].booking * this.Data.nights(arrive, depart) : total;
      pets = '?';
      return this.createResv(arrive, depart, booked, roomId, last, status, guests, pets, 'Booking', total);
    };

    Res.prototype.createResv = function(arrive, depart, booked, roomId, last, status, guests, pets, source, total, spa, cust, payments) {
      var resv;
      if (spa == null) {
        spa = false;
      }
      if (cust == null) {
        cust = {};
      }
      if (payments == null) {
        payments = {};
      }
      resv = {};
      resv.nights = this.Data.nights(arrive, depart);
      resv.arrive = arrive;
      resv.depart = depart;
      resv.booked = booked;
      resv.stayto = this.Data.advanceDate(arrive, resv.nights - 1);
      resv.roomId = roomId;
      resv.last = last;
      resv.status = status;
      resv.guests = guests;
      resv.pets = pets;
      resv.source = source;
      resv.resId = this.Data.resId(arrive, roomId);
      resv.total = total;
      resv.price = total / resv.nights;
      resv.tax = Util.toFixed(total * this.Data.tax);
      resv.spaOptOut = this.spaOptOut(roomId, spa);
      resv.charge = Util.toFixed(total + parseFloat(resv.tax) - resv.spaOptOut);
      resv.paid = 0;
      resv.balance = 0;
      resv.cust = cust;
      resv.payments = payments;
      this.updateDaysFromResv(resv);
      return resv;
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
      payment["with"] = method;
      payment.last4 = last4;
      payment.purpose = purpose;
      payment.cc = '';
      payment.exp = '';
      payment.cvc = '';
      return payment;
    };

    Res.prototype.onResId = function(op, doResv, resId) {
      return this.store.on('Res', op, resId, (function(_this) {
        return function(resId, resv) {
          return doResv(resId, resv);
        };
      })(this));
    };

    Res.prototype.onRes = function(op, doResv) {
      return this.store.on('Res', op, 'none', (function(_this) {
        return function(resId, resv) {
          return doResv(resId, resv);
        };
      })(this));
    };

    Res.prototype.onDay = function(op, doDay) {
      return this.store.on('Day', op, 'none', (function(_this) {
        return function(dayId, day) {
          return doDay(dayId, day);
        };
      })(this));
    };

    Res.prototype.insert = function(table, rows, onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe(table, 'insert', 'none', (function(_this) {
        return function(rows) {
          if (onComplete != null) {
            return onComplete(rows);
          }
        };
      })(this));
      this.store.insert(table, rows);
    };

    Res.prototype.select = function(table, rows, onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe(table, 'select', 'none', (function(_this) {
        return function(rows) {
          if (onComplete != null) {
            return onComplete(rows);
          }
        };
      })(this));
      this.store.select(table);
    };

    Res.prototype.make = function(table, rows, onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe(table, 'make', 'none', (function(_this) {
        return function() {
          return _this.insert(table, rows, onComplete != null ? onComplete() : void 0);
        };
      })(this));
      return this.store.make(table);
    };

    Res.prototype.makeTables = function() {
      this.make('Room', Res.Rooms);
      this.store.make('Res');
      return this.store.make('Day');
    };

    Res.prototype.setResvStatus = function(resv, post, purpose) {
      if (post === 'post') {
        if (purpose === 'PayInFull' || purpose === 'Complete') {
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

    Res.prototype.postResv = function(resv) {
      return this.store.add('Res', resv.resId, resv);
    };

    Res.prototype.postPayment = function(resv, post, amount, method, last4, purpose) {
      var payId, status;
      status = this.setResvStatus(resv, post, purpose);
      if (status === 'book' || status === 'depo') {
        payId = this.Data.genPaymentId(resv.resId, resv.payments);
        resv.payments[payId] = this.createPayment(amount, method, last4, purpose);
        resv.paid += amount;
        resv.balance = resv.totals - resv.paid;
        this.postResv(resv);
      }
    };

    Res.prototype.setDay = function(day, status, resId) {
      day.status = status;
      day.resId = resId;
      return day;
    };

    Res.prototype.optSpa = function(roomId) {
      return this.rooms[roomId].spa === 'O';
    };

    Res.prototype.hasSpa = function(roomId) {
      return this.rooms[roomId].spa === 'O' || this.rooms[roomId].spa === 'Y';
    };

    Res.prototype.htmlSelect = function(htmlId, array, choice, klass, max) {
      var elem, htm, j, len, selected, style, where;
      if (klass == null) {
        klass = "";
      }
      if (max == null) {
        max = void 0;
      }
      style = Util.isStr(klass) ? klass : htmlId;
      htm = "<select name=\"" + htmlId + "\" id=\"" + htmlId + "\" class=\"" + style + "\">";
      where = max != null ? function(elem) {
        return elem <= max;
      } : function() {
        return true;
      };
      for (j = 0, len = array.length; j < len; j++) {
        elem = array[j];
        if (!(where(elem))) {
          continue;
        }
        selected = elem === Util.toStr(choice) ? "selected" : "";
        htm += "<option" + (' ' + selected) + ">" + elem + "</option>";
      }
      return htm += "</select>";
    };

    Res.prototype.htmlInput = function(htmlId, klass, value, label, type) {
      var htm;
      if (value == null) {
        value = "";
      }
      if (label == null) {
        label = "";
      }
      if (type == null) {
        type = "text";
      }
      htm = "";
      if (Util.isStr(label)) {
        htm += "<label for=\"" + htmlId + "\" class=\"" + (klass + 'Label') + "\">" + label + "</label>";
      }
      htm += "<input id= \"" + htmlId + "\" class=\"" + klass + "\" value=\"" + value + "\" type=\"" + type + "\">";
      return htm;
    };

    Res.prototype.htmlButton = function(htmlId, klass, title) {
      return "<button id=\"" + htmlId + "\" class=\"btn btn-primary " + klass + "\">" + title + "</button>";
    };

    Res.prototype.makeSelect = function(htmlId, obj) {
      var onSelect;
      onSelect = function(event) {
        return obj[htmlId] = $(event.target).value;
      };
      $('#' + htmlId).change(onSelect);
    };

    Res.prototype.makeInput = function(htmlId, obj) {
      var onInput;
      onInput = function(event) {
        return obj[htmlId] = $(event.target).value;
      };
      $('#' + htmlId).change(onInput);
    };

    return Res;

  })();

}).call(this);
