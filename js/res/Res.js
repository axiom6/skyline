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
      this.rooms = Res.Rooms;
      this.roomKeys = Util.keys(this.rooms);
      this.book = null;
      this.master = null;
      this.days = {};
      this.resvs = {};
      this.order = 'Decend';
      if (this.appName === 'Guest') {
        this.dateRange(this.Data.beg, this.Data.end);
      }
    }

    Res.prototype.dateRange = function(beg, end, onComplete) {
      if (onComplete == null) {
        onComplete = null;
      }
      this.store.subscribe('Day', 'range', 'none', (function(_this) {
        return function(days) {
          var day, dayId, ref;
          _this.days = days;
          ref = _this.days;
          for (dayId in ref) {
            if (!hasProp.call(ref, dayId)) continue;
            day = ref[dayId];
            day.status = _this.Data.toStatus(day.status);
          }
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
          var day, dayId, ref;
          _this.days = days;
          ref = _this.days;
          for (dayId in ref) {
            if (!hasProp.call(ref, dayId)) continue;
            day = ref[dayId];
            day.status = _this.Data.toStatus(day.status);
          }
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
          var ref, resId, resv;
          _this.resvs = resvs;
          ref = _this.resvs;
          for (resId in ref) {
            if (!hasProp.call(ref, resId)) continue;
            resv = ref[resId];
            resv.status = _this.Data.toStatus(resv.status);
          }
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
        return 'Free';
      }
    };

    Res.prototype.getResv = function(date, roomId) {
      var day;
      day = this.day(date, roomId);
      if (day != null) {
        return this.resvs[day.resId];
      } else {
        return null;
      }
    };

    Res.prototype.day = function(date, roomId) {
      var day, dayId;
      dayId = this.Data.dayId(date, roomId);
      day = this.days[dayId];
      if (day != null) {
        return day;
      } else {
        return this.setDay({}, 'Free', 'none');
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
      pets = 0;
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

    Res.prototype.onRes = function(op, doRes) {
      return this.store.on('Res', op, 'none', (function(_this) {
        return function(resId, res) {
          return doRes(resId, res);
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
          resv.status = 'Skyline';
        }
        if (purpose === 'Deposit') {
          resv.status = 'Deposit';
        }
      } else if (post === 'deny') {
        resv.status = 'Free';
      }
      if (!Util.inArray(this.Data.statuses, resv.status)) {
        Util.error('Pay.setResStatus() unknown status ', resv.status);
        resv.status = 'Free';
      }
      return resv.status;
    };

    Res.prototype.addResv = function(resv) {
      this.resvs[resv.resId] = resv;
      return this.store.add('Res', resv.resId, resv);
    };

    Res.prototype.putResv = function(resv) {
      this.resvs[resv.resId] = resv;
      return this.store.put('Res', resv.resId, resv);
    };

    Res.prototype.canResv = function(resv) {
      this.resvs[resv.resId] = resv;
      return this.store.put('Res', resv.resId, resv);
    };

    Res.prototype.postPayment = function(resv, post, amount, method, last4, purpose) {
      var payId, status;
      status = this.setResvStatus(resv, post, purpose);
      if (status === 'Skyline' || status === 'Deposit') {
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

    Res.prototype.htmlInput = function(htmlId, value, klass, label, type) {
      var htm, style;
      if (value == null) {
        value = "";
      }
      if (klass == null) {
        klass = "";
      }
      if (label == null) {
        label = "";
      }
      if (type == null) {
        type = "text";
      }
      style = Util.isStr(klass) ? klass : htmlId;
      htm = "";
      if (Util.isStr(label)) {
        htm += "<label for=\"" + htmlId + "\" class=\"" + (style + 'Label') + "\">" + label + "</label>";
      }
      htm += "<input id= \"" + htmlId + "\" class=\"" + style + "\" value=\"" + value + "\" type=\"" + type + "\">";
      return htm;
    };

    Res.prototype.htmlButton = function(htmlId, klass, title) {
      return "<button id=\"" + htmlId + "\" class=\"btn btn-primary " + klass + "\">" + title + "</button>";
    };

    Res.prototype.makeSelect = function(htmlId, obj) {
      var onSelect;
      onSelect = (function(_this) {
        return function(event) {
          obj[htmlId] = event.target.value;
          return Util.log(htmlId, obj[htmlId]);
        };
      })(this);
      $('#' + htmlId).change(onSelect);
    };

    Res.prototype.makeInput = function(htmlId, obj) {
      var onInput;
      onInput = (function(_this) {
        return function(event) {
          obj[htmlId] = event.target.value;
          return Util.log(htmlId, obj[htmlId]);
        };
      })(this);
      $('#' + htmlId).change(onInput);
    };

    Res.prototype.resvArrayByDate = function(date) {
      var array, dayId, j, len, ref, resId, roomId;
      array = [];
      ref = this.roomKeys;
      for (j = 0, len = ref.length; j < len; j++) {
        roomId = ref[j];
        dayId = this.Data.dayId(date, roomId);
        if (this.days[dayId] != null) {
          resId = this.days[dayId].resId;
          if (this.resvs[resId] != null) {
            array.push(this.resvs[resId]);
          }
        }
      }
      return array;
    };

    Res.prototype.resvArrayByProp = function(beg, end, prop) {
      var array, date, dayId, j, len, ref, resId, resv, resvs, roomId;
      if (!((beg != null) && (end != null))) {
        return [];
      }
      resvs = {};
      array = [];
      ref = this.roomKeys;
      for (j = 0, len = ref.length; j < len; j++) {
        roomId = ref[j];
        date = beg;
        while (date <= end) {
          dayId = this.Data.dayId(date, roomId);
          if (this.days[dayId] != null) {
            resId = this.days[dayId].resId;
            if (this.resvs[resId] != null) {
              resvs[resId] = this.resvs[resId];
            }
          }
          date = this.Data.advanceDate(date, 1);
        }
      }
      for (resId in resvs) {
        if (!hasProp.call(resvs, resId)) continue;
        resv = resvs[resId];
        array.push(resv);
      }
      this.order = this.order === 'Decend' ? 'Ascend' : 'Decend';
      return Util.quicksort(array, prop, this.order);
    };

    Res.prototype.resvSortDebug = function(array, prop, order) {
      var i, j, k, ref, ref1;
      for (i = j = 0, ref = array.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        Util.log(array[i][prop]);
      }
      this.order = this.order === 'Decend' ? 'Ascend' : 'Decend';
      array = Util.quicksort(array, prop, order);
      Util.log('------ Res.sortArray() end');
      for (i = k = 0, ref1 = array.length; 0 <= ref1 ? k < ref1 : k > ref1; i = 0 <= ref1 ? ++k : --k) {
        Util.log(array[i][prop]);
      }
      return array;
    };

    return Res;

  })();

}).call(this);
