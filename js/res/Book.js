// Generated by CoffeeScript 1.12.2
(function() {
  var $, Alloc, Book,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Alloc = require('js/res/Alloc');

  Book = (function() {
    module.exports = Book;

    function Book(stream, store, room1, cust, res, pay, pict, Data) {
      this.stream = stream;
      this.store = store;
      this.room = room1;
      this.cust = cust;
      this.res = res;
      this.pay = pay;
      this.pict = pict;
      this.Data = Data;
      this.insert = bind(this.insert, this);
      this.make = bind(this.make, this);
      this.onAlloc = bind(this.onAlloc, this);
      this.onCellBook = bind(this.onCellBook, this);
      this.onBook = bind(this.onBook, this);
      this.onHold = bind(this.onHold, this);
      this.onTest = bind(this.onTest, this);
      this.onDay = bind(this.onDay, this);
      this.onMonth = bind(this.onMonth, this);
      this.onPets = bind(this.onPets, this);
      this.onGuests = bind(this.onGuests, this);
      this.updatePrice = bind(this.updatePrice, this);
      this.calcPrice = bind(this.calcPrice, this);
      this.onGoToPay = bind(this.onGoToPay, this);
      this.rooms = this.room.rooms;
      this.roomUIs = this.room.roomUIs;
      this.myDays = 0;
      this.today = new Date();
      this.monthIdx = this.today.getMonth();
      this.monthIdx = 4 <= this.monthIdx && this.monthIdx <= 9 ? this.monthIdx : 4;
      this.year = 2017;
      this.month = this.Data.months[this.monthIdx];
      this.numDays = 15;
      this.begMay = 15;
      this.begDay = this.month === 'May' ? this.begMay : 1;
      this.$cells = [];
      this.myResId = this.res.myResId;
      this.myCustId = this.res.myCustId;
      this.totals = 0;
      this.method = 'site';
      this.myRes = null;
    }

    Book.prototype.ready = function() {
      $('#Book').append(this.bookHtml());
      $('#Inits').append(this.initsHtml());
      $('#Rooms').append(this.roomsHtml(this.year, this.monthIdx, this.begDay, this.numDays));
      $('#Guest').append(this.guestHtml());
      $('.guests').change(this.onGuests);
      $('.pets').change(this.onPets);
      $('#Months').change(this.onMonth);
      $('#Days').change(this.onDay);
      $('#FormName').submit((function(_this) {
        return function(e) {
          return _this.onGoToPay(e);
        };
      })(this)).prop('disabled', true);
      $('#Navb').hide();
      $('#Book').show();
      return this.roomsJQuery();
    };

    Book.prototype.bookHtml = function() {
      return "<div id=\"Make\" class=\"Title\">Make Your Reservation</div>\n<div id=\"Inits\"></div>\n<div id=\"Rooms\"></div>\n<div id=\"Guest\"></div>";
    };

    Book.prototype.bookHtml2 = function() {
      return "<div   class=\"Instruct\">\n  <ul  class=\"Instruct1\">\n    <li>For each room select:</li>\n  </ul>\n  <ul class=\"Instruct2\">\n    <li>Number of Guests</li>\n  </ul>\n  <ul class=\"Instruct3\">\n    <li>Number of Pets</li>\n  </ul>\n  <ul class=\"Instruct4\">\n    <li>Click the days you want</li>\n  </ul>\n</div>\n<div id=\"Inits\"></div>\n<div id=\"Rooms\"></div>\n<div id=\"Confirm\"></div>";
    };

    Book.prototype.initsHtml = function() {
      var htm;
      htm = "<label for=\"Months\" class=\"init-font\">Arrive:" + (this.htmlSelect("Months", this.Data.season, this.month, 'months')) + "</label>";
      htm += "<label for=\"Days\"   class=\"init-font\">       " + (this.htmlSelect("Days", this.Data.days, this.begDay, 'days')) + "</label>";
      htm += "<label class=\"init-font\">&nbsp;&nbsp;" + this.year + "</label>";
      return htm;
    };

    Book.prototype.seeRoom = function(roomId, room) {
      return room.name;
    };

    Book.prototype.roomsHtml = function(year, monthIdx, begDay, numDays) {
      var day, htm, i, j, k, l, ref, ref1, ref2, ref3, ref4, room, roomId, weekday, weekdayIdx;
      weekdayIdx = new Date(year, monthIdx, 1).getDay();
      htm = "<table><thead>";
      htm += "<tr><th></th><th></th><th></th><th></th>";
      for (day = i = 1, ref = this.numDays; 1 <= ref ? i <= ref : i >= ref; day = 1 <= ref ? ++i : --i) {
        weekday = this.Data.weekdays[(weekdayIdx + this.begDay + day - 2) % 7];
        htm += "<th>" + weekday + "</th>";
      }
      htm += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Price</th>";
      for (day = j = 1, ref1 = this.numDays; 1 <= ref1 ? j <= ref1 : j >= ref1; day = 1 <= ref1 ? ++j : --j) {
        htm += "<th>" + (this.dayMonth(day)) + "</th>";
      }
      htm += "<th>Total</th></tr></thead><tbody>";
      ref2 = this.rooms;
      for (roomId in ref2) {
        if (!hasProp.call(ref2, roomId)) continue;
        room = ref2[roomId];
        htm += "<tr id=\"" + roomId + "\"><td>" + (this.seeRoom(roomId, room)) + "</td><td class=\"guests\">" + (this.g(roomId)) + "</td><td class=\"pets\">" + (this.p(roomId)) + "</td><td id=\"" + roomId + "M\" class=\"room-price\">" + ('$' + this.calcPrice(roomId)) + "</td>";
        for (day = k = 1, ref3 = numDays; 1 <= ref3 ? k <= ref3 : k >= ref3; day = 1 <= ref3 ? ++k : --k) {
          htm += this.createCell(roomId, room, this.toDateStr(day));
        }
        htm += "<td class=\"room-total\" id=\"" + roomId + "T\"></td></tr>";
      }
      htm += "<tr>";
      for (day = l = 1, ref4 = this.numDays + 4; 1 <= ref4 ? l <= ref4 : l >= ref4; day = 1 <= ref4 ? ++l : --l) {
        htm += "<td></td>";
      }
      htm += "<td class=\"room-total\" id=\"Totals\">&nbsp;</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Book.prototype.guestHtml = function() {
      return "<form novalidate autocomplete=\"on\" method=\"POST\" id=\"FormName\">\n  <div id=\"Names\">\n    <span class=\"SpanIp\">\n      <label for=\"First\" class=\"control-label\">First Name</label>\n      <input id= \"First\" type=\"text\" class=\"input-lg form-control\" autocomplete=\"given-name\" required>\n      <div   id= \"FirstER\" class=\"NameER\">* Required</div>\n    </span>\n\n    <span class=\"SpanIp\">\n      <label for=\"Last\" class=\"control-label\">Last Name</label>\n      <input id= \"Last\" type=\"text\" class=\"input-lg form-control\" autocomplete=\"family-name\" required>\n      <div   id= \"LastER\" class=\"NameER\">* Required</div>\n    </span>\n\n    <span class=\"SpanIp\">\n      <label for=\"Phone\" class=\"control-label\">Phone</label>\n      <input id= \"Phone\" type=\"tel\" class=\"input-lg form-control\" autocomplete=\"off\" placeholder=\"••• ••• ••••\" required>\n      <div   id= \"PhoneER\" class=\"NameER\">* Required</div>\n    </span>\n\n    <span class=\"SpanIp\">\n      <label for=\"EMail\"   class=\"control-label\">Email</label>\n      <input id= \"EMail\" type=\"email\" class=\"input-lg form-control\" autocomplete=\"email\" required>\n      <div   id= \"EMailER\" class=\"NameER\">* Required</div>\n    </span>\n  </div>\n  <div id=\"GoToDiv\" style=\"text-align:center;\">\n   <button class=\"btn btn-primary\" type=\"submit\" id=\"GoToPay\">Go To Confirmation and Payment</button>\n  </div>\n</form>";
    };

    Book.prototype.isValid = function(name) {
      var valid, value;
      value = $('#' + name).val();
      valid = Util.isStr(value);
      if (!valid) {
        $('#' + name + 'ER').show();
      }
      return [value, valid];
    };

    Book.prototype.getNamesPhoneEmail = function() {
      var ev, fv, lv, ok, pv, ref, ref1, ref2, ref3;
      ref = this.isValid('First'), this.pay.first = ref[0], fv = ref[1];
      ref1 = this.isValid('Last'), this.pay.last = ref1[0], lv = ref1[1];
      ref2 = this.isValid('Phone'), this.pay.phone = ref2[0], pv = ref2[1];
      ref3 = this.isValid('EMail'), this.pay.email = ref3[0], ev = ref3[1];
      ok = this.totals > 0 && fv && lv && pv && ev;
      Util.log('Book.getNamesPhoneEmail()', this.pay.first, fv, this.pay.last, lv, this.pay.phone, pv, this.pay.email, ev, ok);
      return this.totals > 0 && fv && lv && pv && ev;
    };

    Book.prototype.onGoToPay = function(e) {
      var ok;
      e.preventDefault();
      ok = this.getNamesPhoneEmail();
      if (ok) {
        $('.NameER').hide();
        $('#Book').hide();
        this.onHold();
        this.myRes.total = this.totals;
        this.pay.showConfirmPay(this.myRes);
        this.pay.confirmEmail();
      } else {
        alert('Correct Errors');
      }
    };

    Book.prototype.createCell = function(roomId, room, date) {
      var status;
      status = this.room.dayBooked(room, date);
      return "<td id=\"R" + (roomId + date) + "\" class=\"room-" + status + "\" data-status=\"" + status + "\"></td>";
    };

    Book.prototype.roomsJQuery = function() {
      var $cell, date, day, i, j, len, ref, ref1, ref2, roomId, roomUI;
      ref = this.$cells;
      for (i = 0, len = ref.length; i < len; i++) {
        $cell = ref[i];
        $cell.unbind("click");
      }
      this.$cells = [];
      ref1 = this.roomUIs;
      for (roomId in ref1) {
        roomUI = ref1[roomId];
        roomUI.$ = $('#' + roomId);
        for (day = j = 1, ref2 = this.numDays; 1 <= ref2 ? j <= ref2 : j >= ref2; day = 1 <= ref2 ? ++j : --j) {
          date = this.toDateStr(day);
          $cell = $('#R' + roomId + date);
          $cell.click((function(_this) {
            return function(event) {
              return _this.onCellBook(event);
            };
          })(this));
          this.$cells.push($cell);
        }
      }
    };

    Book.prototype.calcPrice = function(roomId) {
      var guests, pets, price, roomUI;
      roomUI = this.roomUIs[roomId];
      guests = roomUI.resRoom.guests;
      pets = roomUI.resRoom.pets;
      price = this.rooms[roomId][guests] + pets * this.Data.petPrice;
      roomUI.resRoom.price = price;
      return price;
    };

    Book.prototype.updatePrice = function(roomId) {
      $('#' + roomId + 'M').text("" + ('$' + this.calcPrice(roomId)));
      this.updateTotal(roomId);
    };

    Book.prototype.updateTotal = function(roomId) {
      var price, room, text;
      price = this.calcPrice(roomId);
      room = this.roomUIs[roomId];
      room.resRoom.total = price * room.numDays;
      text = room.resRoom.total === 0 ? '' : '$' + room.resRoom.total;
      $('#' + roomId + 'T').text(text);
      this.updateTotals();
    };

    Book.prototype.newCust = function() {
      return {
        status: 'mine',
        days: [],
        total: 0
      };
    };

    Book.prototype.updateTotals = function() {
      var ref, room, roomId, text;
      this.totals = 0;
      ref = this.roomUIs;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        this.totals += room.resRoom.total;
      }
      text = this.totals === 0 ? '' : '$' + this.totals;
      $('#Totals').text(text);
      if (this.totals > 0) {
        $('#GoToPay').prop('disabled', false);
      }
    };

    Book.prototype.toDay = function(date) {
      if (date.charAt(6) === '0') {
        return date.substr(7, 8);
      } else {
        return date.substr(6, 8);
      }
    };

    Book.prototype.g = function(roomId) {
      return this.htmlSelect(roomId + 'G', this.Data.persons, 2, 'guests', this.rooms[roomId].max);
    };

    Book.prototype.p = function(roomId) {
      return this.htmlSelect(roomId + 'P', this.Data.pets, 0, 'pets', 3);
    };

    Book.prototype.htmlSelect = function(htmlId, array, choice, klass, max) {
      var elem, htm, i, len, selected, where;
      if (max == null) {
        max = void 0;
      }
      htm = "<select name=\"" + htmlId + "\" id=\"" + htmlId + "\" class=\"" + klass + "\">";
      where = max != null ? function(elem) {
        return elem <= max;
      } : function() {
        return true;
      };
      for (i = 0, len = array.length; i < len; i++) {
        elem = array[i];
        if (!(where(elem))) {
          continue;
        }
        selected = elem === Util.toStr(choice) ? "selected" : "";
        htm += "<option" + (' ' + selected) + ">" + elem + "</option>";
      }
      return htm += "</select>";
    };

    Book.prototype.onGuests = function(event) {
      var roomId;
      roomId = $(event.target).attr('id').charAt(0);
      this.roomUIs[roomId].resRoom.guests = event.target.value;
      Util.log('Book.onGuests', roomId, this.roomUIs[roomId].guests, this.calcPrice(roomId));
      this.updatePrice(roomId);
    };

    Book.prototype.onPets = function(event) {
      var roomId;
      roomId = $(event.target).attr('id').charAt(0);
      this.roomUIs[roomId].resRoom.pets = event.target.value;
      Util.log('Book.onPets', roomId, this.roomUIs[roomId].pets, this.calcPrice(roomId));
      this.updatePrice(roomId);
    };

    Book.prototype.onMonth = function(event) {
      this.month = event.target.value;
      this.monthIdx = this.Data.months.indexOf(this.month);
      this.begDay = this.month === 'May' ? this.begMay : 1;
      $('#Days').val(this.begDay.toString());
      Util.log('Book.onMonth()', {
        monthIdx: this.monthIdx,
        month: this.month,
        begDay: this.begDay
      });
      this.resetRooms();
    };

    Book.prototype.onDay = function(event) {
      this.begDay = parseInt(event.target.value);
      if (this.month === 'October' && this.begDay > 1) {
        this.begDay = 1;
        alert('The Season Ends on October 15');
      } else {
        this.resetRooms();
      }
    };

    Book.prototype.resetRooms = function() {
      $('#Rooms').empty();
      $('#Rooms').append(this.roomsHtml(this.year, this.monthIdx, this.begDay, this.numDays));
      return this.roomsJQuery();
    };

    Book.prototype.onTest = function() {
      Util.log('Book.onTest()');
      return this.store.insert('Alloc', Alloc.Allocs);
    };

    Book.prototype.onHold = function() {
      var onAdd, ref, room, roomId;
      this.myRes = this.res.createHold(this.totals, 'hold', this.method, this.myCustId, this.roomUIs, {});
      Util.log('Book.onHold()', this.myRes);
      ref = this.myRes.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        onAdd = {};
        onAdd.days = room.days;
        this.store.add('Alloc', roomId, onAdd);
      }
    };

    Book.prototype.onBook = function() {
      var date, day, onPut, ref, ref1, room, roomId;
      if (this.myRes == null) {
        this.onHold();
      }
      this.myRes.payments = {};
      this.myRes.payments['1'] = this.res.resPay();
      ref = this.myRes.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        ref1 = room.days;
        for (date in ref1) {
          if (!hasProp.call(ref1, date)) continue;
          day = ref1[date];
          day.status = 'book';
        }
        onPut = {};
        onPut.days = room.days;
        this.store.put('Alloc', roomId, onPut);
      }
      Util.log('Book.onBook()', this.myRes);
    };

    Book.prototype.onCellBook = function(event) {
      var $cell, date, roomId, roomUI, status;
      $cell = $(event.target);
      status = $cell.attr('data-status');
      if (status === 'free') {
        status = 'mine';
      } else if (status === 'mine') {
        status = 'free';
      }
      this.cellStatus($cell, status);
      roomId = $cell.attr('id').substr(1, 1);
      date = $cell.attr('id').substr(2, 8);
      roomUI = this.roomUIs[roomId];
      if (status === 'mine') {
        roomUI.numDays += 1;
        roomUI.resRoom.days[date] = {
          "status": "hold"
        };
      } else {
        if (roomUI.numDays > 0) {
          roomUI.numDays -= 1;
        }
        delete roomUI.resRoom.days[date];
      }
      Util.log('Book.onCellBook()', roomId, date, status, roomUI.resRoom.days);
      return this.updateTotal(roomId);
    };

    Book.prototype.onAlloc = function(alloc, roomId) {
      var day, obj, ref;
      ref = alloc.days;
      for (day in ref) {
        if (!hasProp.call(ref, day)) continue;
        obj = ref[day];
        this.allocCell(day, obj.status, roomId);
      }
    };

    Book.prototype.allocCell = function(day, status, roomId) {
      return this.cellStatus($('#R' + roomId + day), status);
    };

    Book.prototype.cellStatus = function($cell, status) {
      return $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    Book.prototype.dayMonth = function(day) {
      var monthDay;
      monthDay = day + this.begDay - 1;
      if (monthDay > this.Data.numDayMonth[this.monthIdx]) {
        return monthDay - this.Data.numDayMonth[this.monthIdx];
      } else {
        return monthDay;
      }
    };

    Book.prototype.toDateStr = function(day) {
      return this.year + Util.pad(this.monthIdx + 1) + Util.pad(this.dayMonth(day, this.begDay));
    };

    Book.prototype.make = function() {
      return this.store.make('Room');
    };

    Book.prototype.insert = function() {
      return this.store.insert('Room', this.rooms);
    };


    /*
      switch name
        when 'First' then Util.isStr( value )
        when 'Last'  then Util.isStr( value )
        when 'Phone' then Util.isStr( value )
        when 'EMail' then Util.isStr( value )
        else
          Util.error( "Book.isValid() unknown #id", name )
          Util.isStr( value )
     */

    return Book;

  })();

}).call(this);
