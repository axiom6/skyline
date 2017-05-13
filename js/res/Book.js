// Generated by CoffeeScript 1.12.2
(function() {
  var $, Book,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Book = (function() {
    module.exports = Book;

    function Book(stream, store, Data, res, pay, pict) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.pay = pay;
      this.pict = pict;
      this.onAlloc = bind(this.onAlloc, this);
      this.onCellBook = bind(this.onCellBook, this);
      this.onTest = bind(this.onTest, this);
      this.onPop = bind(this.onPop, this);
      this.resetRooms = bind(this.resetRooms, this);
      this.onDay = bind(this.onDay, this);
      this.onMonth = bind(this.onMonth, this);
      this.onSpa = bind(this.onSpa, this);
      this.onPets = bind(this.onPets, this);
      this.onGuests = bind(this.onGuests, this);
      this.updatePrice = bind(this.updatePrice, this);
      this.calcPrice = bind(this.calcPrice, this);
      this.onGoToPay = bind(this.onGoToPay, this);
      this.rooms = this.res.rooms;
      this.roomUIs = this.res.createRoomUIs(this.rooms);
      this.res.book = this;
      this.$cells = [];
      this.totals = 0;
      this.method = 'site';
    }

    Book.prototype.ready = function() {
      $('#Book').empty();
      $('#Pays').empty();
      $('#Book').append(this.bookHtml());
      $('#Insts').append(this.instructHtml());
      $('#Inits').append(this.initsHtml());
      $('#Rooms').append(this.roomsHtml(this.res.year, this.res.monthIdx, this.res.begDay, this.res.numDays));
      $('#Guest').append(this.guestHtml());
      $('.guests').change(this.onGuests);
      $('.pets').change(this.onPets);
      $('.SpaCheck').change(this.onSpa);
      $('#Months').change(this.onMonth);
      $('#Days').change(this.onDay);
      $('#Pop').click(this.onPop);
      $('#Test').click(this.onTest);
      $('#GoToPay').click(this.onGoToPay);
      $('#Navb').hide();
      $('#Book').show();
      return this.roomsJQuery();
    };

    Book.prototype.bookHtml = function() {
      return "<div id=\"Make\" class=\"Title\">Make Your Reservation</div>\n<div id=\"Insts\"></div>\n<div id=\"Inits\"></div>\n<div id=\"Rooms\"></div>\n<div id=\"Guest\"></div>";
    };

    Book.prototype.instructHtml = function() {
      return "<div   class=\"Instruct\">\n  <div>1. Select Month and Day of Arrival 2. Then for each Room Select:</div>\n  <div style=\"padding-left:16px;\">3. Number of Guests 4. Number of Pets 5. Click the Days</div>\n  <div>6. Enter Contact Information: First Last Names, Phone and EMail</div>\n</div>";
    };

    Book.prototype.initsHtml = function() {
      var htm;
      htm = "<label for=\"Months\" class=\"InitIp\">Start: " + (this.htmlSelect("Months", this.Data.season, this.res.month, 'months')) + "</label>";
      htm += "<label for=\"Days\"   class=\"InitIp\">       " + (this.htmlSelect("Days", this.Data.days, this.res.begDay, 'days')) + "</label>";
      htm += "<label class=\"InitIp\">&nbsp;&nbsp;" + (2000 + this.res.year) + "</label>";
      htm += "<span  id=\"Pop\"  class=\"Test\">Pop</span>";
      htm += "<span  id=\"Test\" class=\"Test\">Test</span>";
      return htm;
    };

    Book.prototype.seeRoom = function(roomId, room) {
      return room.name;
    };

    Book.prototype.roomsHtml = function(year, monthIdx, begDay, numDays) {
      var day, htm, i, j, k, l, ref, ref1, ref2, ref3, ref4, room, roomId, weekday, weekdayIdx;
      weekdayIdx = new Date(2000 + year, monthIdx, 1).getDay();
      htm = "<table><thead>";
      htm += "<tr><th></th><th></th><th></th><th></th><th></th>";
      for (day = i = 1, ref = numDays; 1 <= ref ? i <= ref : i >= ref; day = 1 <= ref ? ++i : --i) {
        weekday = this.Data.weekdays[(weekdayIdx + begDay + day - 2) % 7];
        htm += "<th>" + weekday + "</th>";
      }
      htm += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th>";
      for (day = j = 1, ref1 = numDays; 1 <= ref1 ? j <= ref1 : j >= ref1; day = 1 <= ref1 ? ++j : --j) {
        htm += "<th>" + (this.res.dayMonth(day)) + "</th>";
      }
      htm += "<th>Total</th></tr></thead><tbody>";
      ref2 = this.rooms;
      for (roomId in ref2) {
        if (!hasProp.call(ref2, roomId)) continue;
        room = ref2[roomId];
        htm += "<tr id=\"" + roomId + "\"><td class=\"td-left\">" + (this.seeRoom(roomId, room)) + "</td><td class=\"guests\">" + (this.g(roomId)) + "</td><td class=\"pets\">" + (this.p(roomId)) + "</td><td>" + (this.spa(roomId)) + "</td><td id=\"" + roomId + "M\" class=\"room-price\">" + ('$' + this.calcPrice(roomId)) + "</td>";
        for (day = k = 1, ref3 = numDays; 1 <= ref3 ? k <= ref3 : k >= ref3; day = 1 <= ref3 ? ++k : --k) {
          htm += this.createCell(roomId, room, this.res.toDateStr(day));
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

    Book.prototype.getCust = function(testing) {
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
      ref = this.getCust(), tv = ref[0], fv = ref[1], lv = ref[2], pv = ref[3], ev = ref[4], cust = ref[5];
      if (tv && fv && lv && pv && ev) {
        $('.NameER').hide();
        $('#Book').hide();
        this.pay.initPay(this.totals, cust, this.roomUIs);
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

    Book.prototype.createCell = function(roomId, roomRm, date) {
      var status;
      status = this.res.dayBooked(roomId, date);
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
        for (day = j = 1, ref2 = this.res.numDays; 1 <= ref2 ? j <= ref2 : j >= ref2; day = 1 <= ref2 ? ++j : --j) {
          date = this.res.toDateStr(day);
          $cell = $('#R' + roomId + date);
          $cell.click((function(_this) {
            return function(event) {
              return _this.onCellBook(event);
            };
          })(this));
          this.$cells.push($cell);
          this.updateTotal(roomId);
        }
      }
    };

    Book.prototype.calcPrice = function(roomId) {
      var guests, pets, price, roomUI;
      roomUI = this.roomUIs[roomId];
      guests = roomUI.guests;
      pets = roomUI.pets;
      price = this.rooms[roomId][guests] + pets * this.Data.petPrice;
      roomUI.price = price;
      return price;
    };

    Book.prototype.updatePrice = function(roomId) {
      $('#' + roomId + 'M').text("" + ('$' + this.calcPrice(roomId)));
      this.updateTotal(roomId);
    };

    Book.prototype.updateTotal = function(roomId) {
      var nights, price, room, text;
      price = this.calcPrice(roomId);
      room = this.roomUIs[roomId];
      nights = Util.keys(room.days).length;
      room.total = price * nights + room.change;
      text = room.total === 0 ? '' : '$' + room.total;
      $('#' + roomId + 'T').text(text);
      this.updateTotals();
    };

    Book.prototype.updateTotals = function() {
      var ref, room, roomId, text;
      this.totals = 0;
      ref = this.roomUIs;
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
      this.roomUIs[roomId].guests = event.target.value;
      this.updatePrice(roomId);
    };

    Book.prototype.onPets = function(event) {
      var roomId;
      roomId = $(event.target).attr('id').charAt(0);
      this.roomUIs[roomId].pets = event.target.value;
      this.updatePrice(roomId);
    };

    Book.prototype.spa = function(roomId) {
      if (this.res.optSpa(roomId)) {
        return "<input id=\"" + roomId + "SpaCheck\" class=\"SpaCheck\" type=\"checkbox\" value=\"" + roomId + "\" checked>";
      } else {
        return "";
      }
    };

    Book.prototype.onSpa = function(event) {
      var $elem, checked, reason, roomId, roomUI, spaFee;
      $elem = $(event.target);
      roomId = $elem.attr('id').charAt(0);
      roomUI = this.roomUIs[roomId];
      checked = $elem.is(':checked');
      spaFee = checked ? 20 : -20;
      reason = checked ? 'Spa Added' : 'Spa Opted Out';
      roomUI.change += spaFee;
      roomUI.reason = reason;
      if (roomUI.total > 0) {
        this.updateTotal(roomId);
      }
    };

    Book.prototype.onMonth = function(event) {
      this.res.month = event.target.value;
      this.res.monthIdx = this.Data.months.indexOf(this.month);
      this.res.begDay = this.month === 'May' ? this.begMay : 1;
      $('#Days').val(this.res.begDay.toString());
      this.res.dateRange(this.resetRooms);
      this.resetRooms();
    };

    Book.prototype.onDay = function(event) {
      this.res.begDay = parseInt(event.target.value);
      if (this.res.month === 'October' && this.res.begDay > 1) {
        this.res.begDay = 1;
        alert('The Season Ends on October 15');
      }
      this.res.dateRange(this.resetRooms);
      this.resetRooms();
    };

    Book.prototype.resetRooms = function() {
      $('#Rooms').empty();
      $('#Rooms').append(this.roomsHtml(this.res.year, this.res.monthIdx, this.res.begDay, this.res.numDays));
      return this.roomsJQuery();
    };

    Book.prototype.onPop = function() {
      this.getCust(true);
      this.pay.testing = true;
    };

    Book.prototype.onTest = function() {
      if (this.test != null) {
        this.test.doTest();
      }
    };

    Book.prototype.onCellBook = function(event) {
      var $cell, ref, roomId, status;
      $cell = $(event.target);
      ref = this.cellBook($cell), roomId = ref[0], status = ref[1];
      if (status === 'mine') {
        return this.fillInRooms(roomId, $cell);
      }
    };

    Book.prototype.cellBook = function($cell) {
      var group, isEmpty, roomId, status;
      status = $cell.attr('data-status');
      roomId = $cell.attr('id').substr(1, 1);
      group = this.roomUIs[roomId].group;
      isEmpty = Util.isObjEmpty(group);
      if (status === 'free') {
        status = 'mine';
        this.updateCellStatus($cell, 'mine');
      } else if (status === 'mine' && isEmpty) {
        status = 'free';
        this.updateCellStatus($cell, 'free');
      } else if (status === 'mine' && !isEmpty) {
        status = 'free';
        this.updateCellGroup(roomId, group, 'free');
      }
      return [roomId, status];
    };

    Book.prototype.updateCellGroup = function(roomId, group, status) {
      var $cell, day, obj;
      for (day in group) {
        if (!hasProp.call(group, day)) continue;
        obj = group[day];
        $cell = $('#R' + roomId + day);
        Util.log('Book.updateCellGroup()', {
          day: day,
          group: group
        });
        this.updateCellStatus($cell, status);
      }
    };

    Book.prototype.updateCellStatus = function($cell, status) {
      var date, roomId, roomUI;
      this.cellStatus($cell, status);
      roomId = $cell.attr('id').substr(1, 1);
      date = $cell.attr('id').substr(2, 8);
      roomUI = this.roomUIs[roomId];
      if (status === 'mine') {
        roomUI.days[date] = {
          "status": status,
          "resId": ""
        };
      } else if (status === 'free') {
        delete roomUI.days[date];
        if (roomUI.group[date] != null) {
          delete roomUI.group[date];
        }
      }
      this.updateTotal(roomId);
      return [roomId, status];
    };

    Book.prototype.fillInRooms = function(roomId, $last) {
      var bday, days, roomUI, weekday, weekend;
      roomUI = this.roomUIs[roomId];
      days = Util.keys(roomUI.days).sort();
      bday = days[0];
      weekday = this.Data.weekday(days[0]);
      weekend = weekday === 'Fri' || weekday === 'Sat';
      if (days.length === 1 && weekend) {
        this.fillInWeekend(roomId, bday);
      } else if (days.length === 2 && this.fillIsConsistent(roomId, days, $last)) {
        this.doFillInRooms(roomId, days);
      }
    };

    Book.prototype.fillInWeekend = function(roomId, bday) {
      var group, nday;
      nday = this.Data.advanceDate(bday, 1);
      if ($('#R' + roomId + nday).attr('data-status') === 'free') {
        group = this.roomUIs[roomId].group;
        group[bday] = {
          status: 'mine'
        };
        group[nday] = {
          status: 'mine'
        };
        this.updateCellStatus($('#R' + roomId + nday), 'mine');
      }
    };

    Book.prototype.fillIsConsistent = function(roomId, days, $last) {
      var $cell, bday, eday, nday;
      bday = days[0];
      eday = days[days.length - 1];
      nday = this.Data.advanceDate(bday, 1);
      while (nday < eday) {
        $cell = $('#R' + roomId + nday);
        if (!this.Data.isElem($cell) || $cell.attr('data-status') !== 'free') {
          $last.attr('data-status', 'mine');
          this.cellBook($last);
          return false;
        }
        nday = this.Data.advanceDate(nday, 1);
      }
      return true;
    };

    Book.prototype.doFillInRooms = function(roomId, days) {
      var $cell, bday, eday, nday;
      bday = days[0];
      nday = this.Data.advanceDate(bday, 1);
      eday = days[days.length - 1];
      while (nday < eday) {
        $cell = $('#R' + roomId + nday);
        if (this.Data.isElem($('#R' + roomId + nday))) {
          this.cellBook($cell);
        }
        nday = this.Data.advanceDate(nday, 1);
      }
    };

    Book.prototype.onAlloc = function(roomId, days) {
      var day, dayId;
      for (dayId in days) {
        if (!hasProp.call(days, dayId)) continue;
        day = days[dayId];
        this.allocCell(dayId, day.status, roomId);
      }
    };

    Book.prototype.allocCell = function(dayId, status, roomId) {
      return this.cellStatus($('#R' + roomId + dayId), status);
    };

    Book.prototype.cellStatus = function($cell, status) {
      return $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    return Book;

  })();

}).call(this);
