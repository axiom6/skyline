// Generated by CoffeeScript 1.12.2
(function() {
  var $, Book, Data, UI,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Data = require('js/res/Data');

  UI = require('js/res/UI');

  Book = (function() {
    module.exports = Book;

    function Book(stream, store, res, pay, pict) {
      this.stream = stream;
      this.store = store;
      this.res = res;
      this.pay = pay;
      this.pict = pict;
      this.allocDays = bind(this.allocDays, this);
      this.onCellBook = bind(this.onCellBook, this);
      this.onTest = bind(this.onTest, this);
      this.onPop = bind(this.onPop, this);
      this.resetRooms2 = bind(this.resetRooms2, this);
      this.resetRooms = bind(this.resetRooms, this);
      this.onDay = bind(this.onDay, this);
      this.onMonth = bind(this.onMonth, this);
      this.onSpa = bind(this.onSpa, this);
      this.onPets = bind(this.onPets, this);
      this.onGuests = bind(this.onGuests, this);
      this.calcPrice = bind(this.calcPrice, this);
      this.onGoToPay = bind(this.onGoToPay, this);
      this.rooms = this.res.rooms;
      this.res.book = this;
      this.$cells = [];
      this.last = null;
      this.totals = 0;
      this.method = 'site';
    }

    Book.prototype.ready = function() {
      var onComplete;
      this.res.roomUI(this.rooms);
      $('#Book').empty();
      $('#Pays').empty();
      $('#Book').append(this.bookHtml());
      $('#Insts').append(this.instructHtml());
      $('#Inits').append(this.initsHtml());
      $('#Guest').append(this.guestHtml());
      $('.guests').change(this.onGuests);
      $('.pets').change(this.onPets);
      $('.SpaCheck').change(this.onSpa);
      $('#Months').change(this.onMonth);
      $('#Days').change(this.onDay);
      $('#Pop').click(this.onPop);
      $('#Test').click(this.onTest);
      $('#GoToPay').click(this.onGoToPay);
      $('#Totals').css({
        height: '21px'
      });
      $('#Navb').hide();
      onComplete = (function(_this) {
        return function() {
          $('#Rooms').append(_this.roomsHtml(Data.year, Data.monthIdx, Data.begDay, Data.numDays));
          _this.roomsJQuery();
          return $('#Book').show();
        };
      })(this);
      this.res.dateRange(Data.beg, Data.end, onComplete);
    };

    Book.prototype.bookHtml = function() {
      return "<div id=\"Make\" class=\"Title\">Make Your Reservation</div>\n<div id=\"Insts\"></div>\n<div><div id=\"Inits\"></div></div>\n<div id=\"Rooms\"></div>\n<div id=\"Guest\"></div>";
    };

    Book.prototype.instructHtml = function() {
      return "<div   class=\"Instruct\">\n  <div>1. Select Month and Day of Arrival 2. Then for each Room Select:</div>\n  <div style=\"padding-left:16px;\">3. Number of Guests 4. Number of Pets 5. Click the Days</div>\n  <div>6. Enter Contact Information: First Last Names, Phone and EMail</div>\n</div>";
    };

    Book.prototype.initsHtml = function() {
      var htm;
      htm = "<label for=\"Months\" class=\"InitIp\">Start: " + (UI.htmlSelect("Months", Data.season, Data.month())) + "</label>";
      htm += "<label for=\"Days\"   class=\"InitIp\">       " + (UI.htmlSelect("Days", Data.days, Data.begDay)) + "</label>";
      htm += "<label class=\"InitIp\">&nbsp;&nbsp;" + (2000 + Data.year) + "</label>";
      htm += "<span  id=\"Pop\"  class=\"Test\">Pop</span>";
      htm += "<span  id=\"Test\" class=\"Test\">Test</span>";
      return htm;
    };

    Book.prototype.seeRoom = function(roomId, room) {
      return room.name;
    };

    Book.prototype.roomsHtml = function(year, monthIdx, begDay, numDays) {
      var date, day, htm, i, j, k, l, ref, ref1, ref2, ref3, ref4, room, roomId, weekday, weekdayIdx;
      weekdayIdx = new Date(2000 + year, monthIdx, 1).getDay();
      htm = "<table><thead>";
      htm += "<tr><th></th><th></th><th></th><th></th><th></th>";
      for (day = i = 1, ref = numDays; 1 <= ref ? i <= ref : i >= ref; day = 1 <= ref ? ++i : --i) {
        weekday = Data.weekdays[(weekdayIdx + begDay + day - 2) % 7];
        htm += "<th>" + weekday + "</th>";
      }
      htm += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th>";
      for (day = j = 1, ref1 = numDays; 1 <= ref1 ? j <= ref1 : j >= ref1; day = 1 <= ref1 ? ++j : --j) {
        htm += "<th>" + (Data.dayMonth(day)) + "</th>";
      }
      htm += "<th>Total</th></tr></thead><tbody>";
      ref2 = this.rooms;
      for (roomId in ref2) {
        if (!hasProp.call(ref2, roomId)) continue;
        room = ref2[roomId];
        htm += "<tr id=\"" + roomId + "\"><td class=\"td-left\">" + (this.seeRoom(roomId, room)) + "</td><td class=\"guests\">" + (this.g(roomId)) + "</td><td class=\"pets\">" + (this.p(roomId)) + "</td><td>" + (this.spa(roomId)) + "</td><td id=\"" + roomId + "M\" class=\"room-price\">" + ('$' + this.calcPrice(roomId)) + "</td>";
        for (day = k = 1, ref3 = numDays; 1 <= ref3 ? k <= ref3 : k >= ref3; day = 1 <= ref3 ? ++k : --k) {
          date = Data.toDateStr(Data.dayMonth(day));
          htm += this.createCell(date, roomId);
        }
        htm += "<td class=\"room-total\" id=\"" + roomId + "T\"></td></tr>";
      }
      htm += "<tr>";
      for (day = l = 1, ref4 = numDays + 5; 1 <= ref4 ? l <= ref4 : l >= ref4; day = 1 <= ref4 ? ++l : --l) {
        htm += "<td></td>";
      }
      htm += "<td class=\"room-total\" id=\"Totals\">&nbsp;</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Book.prototype.guestHtml = function() {
      var phPtn;
      phPtn = "\d{3} \d{3} \d{4}";
      return "<form autocomplete=\"on\" method=\"POST\" id=\"FormName\">\n  <div id=\"Names\">\n    <span class=\"SpanIp\">\n      <label for=\"First\" class=\"control-label\">First Name</label>\n      <input id= \"First\" type=\"text\" class=\"input-lg form-control\" autocomplete=\"given-name\" required>\n      <div   id= \"FirstER\" class=\"NameER\">* Required</div>\n    </span>\n\n    <span class=\"SpanIp\">\n      <label for=\"Last\" class=\"control-label\">Last Name</label>\n      <input id= \"Last\" type=\"text\" class=\"input-lg form-control\" autocomplete=\"family-name\" required>\n      <div   id= \"LastER\" class=\"NameER\">* Required</div>\n    </span>\n\n    <span class=\"SpanIp\">\n      <label for=\"Phone\" class=\"control-label\">Phone</label>\n      <input id= \"Phone\" type=\"tel\" class=\"input-lg form-control\" placeholder=\"••• ••• ••••\"  pattern=\"" + phPtn + "\" required>\n      <div   id= \"PhoneER\" class=\"NameER\">* Required</div>\n    </span>\n\n    <span class=\"SpanIp\">\n      <label for=\"EMail\"   class=\"control-label\">Email</label>\n      <input id= \"EMail\" type=\"email\" class=\"input-lg form-control\" autocomplete=\"email\" required>\n      <div   id= \"EMailER\" class=\"NameER\">* Required</div>\n    </span>\n  </div>\n  <div id=\"GoToDiv\" style=\"text-align:center;\">\n   <button class=\"btn btn-primary\" type=\"submit\" id=\"GoToPay\">Go To Confirmation and Payment</button>\n  </div>\n</form>";
    };

    Book.prototype.isValid = function(name, test, testing) {
      var valid, value;
      if (testing == null) {
        testing = false;
      }
      value = $('#' + name).val();
      valid = Util.isStr(value);
      if (testing) {
        $('#' + name).val(test);
        value = test;
        valid = true;
      }
      return [value, valid];
    };

    Book.prototype.createCust = function(testing) {
      var cust, email, ev, first, fv, last, lv, phone, pv, ref, ref1, ref2, ref3, tv;
      if (testing == null) {
        testing = false;
      }
      ref = this.isValid('First', 'Samuel', testing), first = ref[0], fv = ref[1];
      ref1 = this.isValid('Last', 'Hosendecker', testing), last = ref1[0], lv = ref1[1];
      ref2 = this.isValid('Phone', '3037977129', testing), phone = ref2[0], pv = ref2[1];
      ref3 = this.isValid('EMail', 'Thomas.Edmund.Flaherty@gmail.com', testing), email = ref3[0], ev = ref3[1];
      tv = this.totals > 0;
      cust = this.res.createCust(first, last, phone, email, "site");
      return [tv, fv, lv, pv, ev, cust];
    };

    Book.prototype.onGoToPay = function(e) {
      var cust, ev, fv, lv, pv, ref, tv;
      if (e != null) {
        e.preventDefault();
      }
      ref = this.createCust(), tv = ref[0], fv = ref[1], lv = ref[2], pv = ref[3], ev = ref[4], cust = ref[5];
      if (tv && fv && lv && pv && ev) {
        $('.NameER').hide();
        $('#Book').hide();
        this.pay.initPayResv(this.totals, cust, this.rooms);
      } else {
        alert(this.onGoToMsg(tv, fv, lv, pv, ev));
      }
    };

    Book.prototype.onGoToMsg = function(tv, fv, lv, pv, ev) {
      var msg;
      msg = "";
      if (!tv) {
        msg += "Total is 0\n";
      }
      if (!tv) {
        msg += "Need to Click Rooms\n";
      }
      if (!fv) {
        msg += "Enter First Name\n";
      }
      if (!lv) {
        msg += "Enter Last  Name\n";
      }
      if (!pv) {
        msg += "Enter Phone Number\n";
      }
      if (!ev) {
        msg += "Enter Email\n";
      }
      return msg;
    };

    Book.prototype.createCell = function(date, roomId) {
      var status, style;
      status = this.res.status(date, roomId);
      style = "background:" + (Data.toColor(status)) + ";";
      return "<td id=\"" + (this.cellId(date, roomId)) + "\" class=\"room-" + status + "\" style=\"" + style + "\"></td>";
    };

    Book.prototype.cellId = function(date, roomId) {
      return 'R' + date + roomId;
    };

    Book.prototype.roomIdCell = function($cell) {
      return $cell.attr('id').substr(7, 1);
    };

    Book.prototype.dateCell = function($cell) {
      return $cell.attr('id').substr(1, 6);
    };

    Book.prototype.$cell = function(date, roomId) {
      return $('#' + this.cellId(date, roomId));
    };

    Book.prototype.roomsJQuery = function() {
      var $cell, date, day, i, j, len, ref, ref1, ref2, room, roomId, status;
      ref = this.$cells;
      for (i = 0, len = ref.length; i < len; i++) {
        $cell = ref[i];
        $cell.unbind("click");
      }
      this.$cells = [];
      ref1 = this.rooms;
      for (roomId in ref1) {
        room = ref1[roomId];
        room.$ = $('#' + roomId);
        for (day = j = 1, ref2 = Data.numDays; 1 <= ref2 ? j <= ref2 : j >= ref2; day = 1 <= ref2 ? ++j : --j) {
          date = Data.toDateStr(Data.dayMonth(day));
          $cell = this.$cell(date, roomId);
          $cell.click((function(_this) {
            return function(event) {
              return _this.onCellBook(event);
            };
          })(this));
          this.$cells.push($cell);
          this.updateTotal(roomId);
          status = this.res.status(date, roomId);
          this.cellStatus($cell, status);
        }
      }
    };

    Book.prototype.calcPrice = function(roomId) {
      var room;
      room = this.rooms[roomId];
      room.price = this.res.calcPrice(roomId, room.guests, room.pets, 'Skyline');
      return room.price;
    };

    Book.prototype.updateTotal = function(roomId) {
      var nights, price, room, text;
      price = this.calcPrice(roomId);
      $('#' + roomId + 'M').text("" + ('$' + price));
      room = this.rooms[roomId];
      nights = Util.keys(room.days).length;
      room.total = price * nights + room.change;
      text = room.total === 0 ? '' : '$' + room.total;
      $('#' + roomId + 'T').text(text);
      this.updateTotals();
    };

    Book.prototype.updateTotals = function() {
      var ref, room, roomId, text;
      this.totals = 0;
      ref = this.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        this.totals += room.total;
      }
      text = this.totals === 0 ? '' : '$' + this.totals;
      $('#Totals').text(text);
      if (this.totals > 0) {
        $('#GoToPay').prop('disabled', false);
      }
    };

    Book.prototype.g = function(roomId) {
      return UI.htmlSelect(roomId + 'G', Data.persons, 2, 'guests', this.rooms[roomId].max);
    };

    Book.prototype.p = function(roomId) {
      return UI.htmlSelect(roomId + 'P', Data.pets, 0, 'pets', 3);
    };

    Book.prototype.onGuests = function(event) {
      var roomId;
      roomId = $(event.target).attr('id').charAt(0);
      this.rooms[roomId].guests = event.target.value;
      this.updateTotal(roomId);
    };

    Book.prototype.onPets = function(event) {
      var roomId;
      roomId = $(event.target).attr('id').charAt(0);
      this.rooms[roomId].pets = event.target.value;
      this.updateTotal(roomId);
    };

    Book.prototype.spa = function(roomId) {
      if (this.res.optSpa(roomId)) {
        return "<input id=\"" + roomId + "SpaCheck\" class=\"SpaCheck\" type=\"checkbox\" value=\"" + roomId + "\" checked>";
      } else {
        return "";
      }
    };

    Book.prototype.onSpa = function(event) {
      var $elem, checked, reason, room, roomId, spaFee;
      $elem = $(event.target);
      roomId = $elem.attr('id').charAt(0);
      room = this.rooms[roomId];
      checked = $elem.is(':checked');
      spaFee = checked ? 20 : -20;
      reason = checked ? 'Spa Added' : 'Spa Opted Out';
      room.change += spaFee;
      room.reason = reason;
      if (room.total > 0) {
        this.updateTotal(roomId);
      }
    };

    Book.prototype.onMonth = function(event) {
      Data.monthIdx = Data.months.indexOf(event.target.value);
      Data.begDay = Data.month() === 'May' ? Data.begMay : 1;
      $('#Days').val(Data.begDay.toString());
      this.resetRooms();
    };

    Book.prototype.onDay = function(event) {
      Data.begDay = parseInt(event.target.value);
      if (Data.month() === 'October' && Data.begDay > 1) {
        Data.begDay = 1;
        alert('The Season Ends on October 15');
      }
      this.resetRooms();
    };

    Book.prototype.resetDateRange = function() {
      var beg, end;
      beg = Data.toDateStr(Data.begDay, Data.monthIdx);
      end = Data.advanceDate(beg, Data.numDays - 1);
      return this.res.dateRange(beg, end, this.resetRooms);
    };

    Book.prototype.resetRooms = function() {};

    Book.prototype.resetRooms2 = function() {
      $('#Rooms').empty();
      $('#Rooms').append(this.roomsHtml(Data.year, Data.monthIdx, Data.begDay, Data.numDays));
      return this.roomsJQuery();
    };

    Book.prototype.onPop = function() {
      this.createCust(true);
      this.pay.testing = true;
    };

    Book.prototype.onTest = function() {
      if (this.test != null) {
        this.test.doTest();
      }
    };

    Book.prototype.onCellBook = function(event) {
      var $cell, date, ref, roomId, status;
      $cell = $(event.target);
      ref = this.cellBook($cell), date = ref[0], roomId = ref[1], status = ref[2];
      if (status === 'Mine') {
        this.fillInCells(this.last, date, roomId, 'Free', status);
      }
      this.last = date;
    };

    Book.prototype.fillInCells = function(begDate, endDate, roomId, free, fill) {
      var $cell, $cells, beg, end, i, len, next, ref, status;
      if (!((begDate != null) && (endDate != null) && (roomId != null))) {
        return;
      }
      ref = Data.begEndDates(begDate, endDate), beg = ref[0], end = ref[1];
      $cells = [];
      next = beg;
      while (next <= end) {
        $cell = this.$cell('M', next, roomId);
        status = this.res.status(next, roomId);
        if (status === free || status === fill || status === 'Cancel') {
          $cells.push($cell);
          next = Data.advanceDate(next, 1);
        } else {
          return [null, null];
        }
      }
      for (i = 0, len = $cells.length; i < len; i++) {
        $cell = $cells[i];
        this.cellStatus($cell, fill);
      }
    };

    Book.prototype.cellBook = function($cell) {
      var date, resId, roomId, status;
      date = this.dateCell($cell);
      roomId = this.roomIdCell($cell);
      resId = Data.resId(date, roomId);
      status = this.res.status(date, roomId);
      if (status === 'Free') {
        status = 'Mine';
        this.updateCellStatus($cell, 'Mine', resId);
      } else if (status === 'Mine') {
        status = 'Free';
        this.updateCellStatus($cell, 'Free', resId);
      }
      return [date, roomId, status];
    };

    Book.prototype.updateCellStatus = function($cell, status, resId) {
      var date, day, nday, roomId, weekday;
      this.cellStatus($cell, status);
      date = this.dateCell($cell);
      roomId = this.roomIdCell($cell);
      resId = Data.resId(date, roomId);
      day = this.res.day(date, roomId);
      if (status === 'Mine') {
        this.res.setDay(day, status, resId);
      } else if (status === 'Free') {
        weekday = Data.weekday(date);
        if (weekday === 'Fri' || weekday === 'Sat') {
          nday = Data.advanceDate(date, 1);
          this.cellStatus(this.$cell(nday, roomId), 'Free');
        }
      }
      this.updateTotal(roomId);
      return [roomId, status];
    };

    Book.prototype.allocDays = function(days) {
      var date, day, dayId, roomId;
      for (dayId in days) {
        if (!hasProp.call(days, dayId)) continue;
        day = days[dayId];
        date = Data.toDate(dayId);
        roomId = Data.roomId(dayId);
        this.allocCell(date, day.status, roomId);
      }
    };

    Book.prototype.allocCell = function(date, status, roomId) {
      return this.cellStatus(this.$cell(date, roomId), status);
    };

    Book.prototype.cellStatus = function($cell, klass) {
      $cell.removeClass().addClass("room-" + klass);
      $cell.css({
        background: Data.toColor(klass)
      });
    };

    return Book;

  })();

}).call(this);
