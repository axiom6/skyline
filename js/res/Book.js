// Generated by CoffeeScript 1.12.2
(function() {
  var $, Book,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Book = (function() {
    module.exports = Book;

    Book.Room = require('data/Room.json');

    Book.Book = require('data/Book.json');

    Book.Alloc = require('data/Alloc.json');

    function Book(stream, store, room1, cust1) {
      this.stream = stream;
      this.store = store;
      this.room = room1;
      this.cust = cust1;
      this.onAlloc = bind(this.onAlloc, this);
      this.onCellBook = bind(this.onCellBook, this);
      this.onTest = bind(this.onTest, this);
      this.onPets = bind(this.onPets, this);
      this.onDay = bind(this.onDay, this);
      this.onMonth = bind(this.onMonth, this);
      this.onGuests = bind(this.onGuests, this);
      this.numDayMonth = [31, 30, 31, 31, 30, 31];
      this.allDayMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      this.months = ["May", "June", "July", "August", "September", "October"];
      this.monthsAll = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      this.weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      this.days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"];
      this.persons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
      this.pets = ["0", "1", "2", "3"];
      this.guests = "2";
      this.pet = 0;
      this.myDays = 0;
      this.petPrice = 12;
      this.today = new Date();
      this.monthIdx = this.today.getMonth();
      this.monthIdx = 2;
      this.year = "2017";
      this.month = this.months[this.monthIdx];
      this.begDay = 9;
      this.weekdayIdx = new Date(2017, this.monthIdx, 1).getDay();
      this.numDays = 14;
      this.$cells = [];
      this.myCustId = "12";
      Util.log('Book Constructor');
    }

    Book.prototype.ready = function() {
      $('#Inits').append(this.initsHtml());
      $('#Rooms').append(this.roomsHtml());
      $('#Guests').change(this.onGuests);
      $('#Pets').change(this.onPets);
      $('#Months').change(this.onMonth);
      $('#Days').change(this.onDay);
      $('#Test').click(this.onTest);
      this.roomsJQuery();
      return this.subscribe();
    };

    Book.prototype.subscribe = function() {
      this.stream.subscribe('Alloc', (function(_this) {
        return function(alloc) {
          return _this.onAlloc(alloc);
        };
      })(this));
    };

    Book.prototype.initsHtml = function() {
      var htm;
      htm = "<label class=\"init-font\">&nbsp;&nbsp;Guests:" + (this.htmlSelect("Guests", this.persons, this.guests)) + "</label>";
      htm += "<label class=\"init-font\">&nbsp;&nbsp;Pets:  " + (this.htmlSelect("Pets", this.pets, this.pet)) + "</label>";
      htm += "<label class=\"init-font\">&nbsp;&nbsp;Arrive:" + (this.htmlSelect("Months", this.months, this.month)) + "</label>";
      htm += "<label class=\"init-font\">&nbsp;&nbsp;       " + (this.htmlSelect("Days", this.days, this.begDay)) + "</label>";
      htm += "<label class=\"init-font\">&nbsp;&nbsp;" + this.year + "</label>";
      htm += "<span  class=\"init-font\" id=\"Test\">&nbsp;&nbsp;Test</span>";
      return htm;
    };

    Book.prototype.roomsHtml = function() {
      var date, day, htm, i, j, k, l, ref, ref1, ref2, ref3, ref4, room, roomId, weekday;
      htm = "<table><thead>";
      htm += "<tr><th></th><th id=\"NumGuests\">" + this.guests + "&nbsp;Guests</th>";
      for (day = i = 1, ref = this.numDays; 1 <= ref ? i <= ref : i >= ref; day = 1 <= ref ? ++i : --i) {
        weekday = this.weekdays[(this.weekdayIdx + day - 1) % 7];
        htm += "<th>" + weekday + "</th>";
      }
      htm += "<th>Room</th></tr><tr><th>Cottage</th><th>" + this.pet + "&nbsp;Pets</th>";
      for (day = j = 1, ref1 = this.numDays; 1 <= ref1 ? j <= ref1 : j >= ref1; day = 1 <= ref1 ? ++j : --j) {
        htm += "<th>" + (this.dayMonth(day)) + "</th>";
      }
      htm += "<th>Total</th></tr></thead><tbody>";
      ref2 = Book.Room;
      for (roomId in ref2) {
        if (!hasProp.call(ref2, roomId)) continue;
        room = ref2[roomId];
        htm += "<tr id=\"" + roomId + "\"><td>" + room.name + "</td><td id=\"" + roomId + "Price\" class=\"room-price\">" + ('$' + this.calcPrice(room)) + "</td>";
        for (day = k = 1, ref3 = this.numDays; 1 <= ref3 ? k <= ref3 : k >= ref3; day = 1 <= ref3 ? ++k : --k) {
          date = this.toDateStr(day);
          htm += this.createCell(roomId, Book.Book[roomId], date);
        }
        htm += "<td class=\"room-total\" id=\"" + roomId + "Total\"></td></tr>";
      }
      htm += "<tr><td></td><td></td>";
      for (day = l = 1, ref4 = this.numDays; 1 <= ref4 ? l <= ref4 : l >= ref4; day = 1 <= ref4 ? ++l : --l) {
        htm += "<td></td>";
      }
      htm += "<td class=\"room-total\" id=\"Totals\">&nbsp;</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Book.prototype.roomsJQuery = function() {
      var $cell, date, day, i, j, len, ref, ref1, ref2, room, roomId;
      ref = this.$cells;
      for (i = 0, len = ref.length; i < len; i++) {
        $cell = ref[i];
        $cell.unbind("click");
      }
      this.$cells = [];
      ref1 = Book.Room;
      for (roomId in ref1) {
        room = ref1[roomId];
        room.$ = $('#' + roomId);
        for (day = j = 1, ref2 = this.numDays; 1 <= ref2 ? j <= ref2 : j >= ref2; day = 1 <= ref2 ? ++j : --j) {
          date = this.toDateStr(day);
          $cell = $('#' + roomId + date);
          $cell.click((function(_this) {
            return function(event) {
              return _this.onCellBook(event);
            };
          })(this));
          this.$cells.push($cell);
        }
      }
    };

    Book.prototype.createCell = function(roomId, book, date) {
      var status;
      status = this.dayBooked(book, date);
      return "<td id=\"" + (roomId + date) + "\" class=\"room-" + status + "\" data-status=\"" + status + "\"></td>";
    };

    Book.prototype.calcPrice = function(room) {
      var price;
      price = room[this.guests] + this.pet * this.petPrice;
      room.price = price;
      return price;
    };

    Book.prototype.updatePrice = function(roomId, room) {
      if (this.guests > room.max) {
        room.$.hide();
      } else {
        room.$.show();
        $('#P' + roomId).text("" + ('$' + this.calcPrice(room)));
      }
    };

    Book.prototype.updatePrices = function() {
      var ref, results, room, roomId;
      ref = Book.Room;
      results = [];
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        results.push(this.updatePrice(roomId, room));
      }
      return results;
    };

    Book.prototype.updateTotal = function(roomId, date, status) {
      var cust, price, text;
      price = Book.Room[roomId].price;
      cust = Book.Book[roomId][this.myCustId];
      if (cust == null) {
        cust = this.newCust();
        Book.Book[roomId][this.myCustId] = cust;
      }
      cust.status = status;
      cust.days.push(date);
      cust.total += status === 'mine' ? price : -price;
      text = cust.total === 0 ? '' : '$' + cust.total;
      $('#' + roomId + 'Total').text(text);
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
      var book, cust, ref, roomId, text, totals;
      totals = 0;
      ref = Book.Book;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        book = ref[roomId];
        cust = book[this.myCustId];
        if (cust != null) {
          totals += book[this.myCustId].total;
        }
      }
      text = totals === 0 ? '' : '$' + totals;
      $('#Totals').text(text);
    };

    Book.prototype.toDay = function(date) {
      if (date.charAt(6) === '0') {
        return date.substr(7, 8);
      } else {
        return date.substr(6, 8);
      }
    };

    Book.prototype.dayBooked = function(book, date) {
      var cust, custId, day, i, len, ref;
      for (custId in book) {
        if (!hasProp.call(book, custId)) continue;
        cust = book[custId];
        ref = cust.days;
        for (i = 0, len = ref.length; i < len; i++) {
          day = ref[i];
          if (day === date) {
            return cust.status;
          }
        }
      }
      return 'free';
    };

    Book.prototype.htmlSelect = function(htmlId, array, choice) {
      var elem, htm, i, len, selected;
      htm = "<select id=\"" + htmlId + "\">";
      for (i = 0, len = array.length; i < len; i++) {
        elem = array[i];
        selected = elem === Util.toStr(choice) ? "selected" : "";
        htm += "<option" + (' ' + selected) + ">" + elem + "</option>";
      }
      return htm += "</select>";
    };

    Book.prototype.onGuests = function(event) {
      this.guests = event.target.value;
      $('#NumGuests').text(this.guests);
      this.updatePrices();
    };

    Book.prototype.onMonth = function(event) {
      this.month = event.target.value;
      this.monthIdx = this.months.indexOf(this.month);
      this.weekdayIdx = new Date(2017, this.monthIdx, 1).getDay();
      this.resetRooms();
    };

    Book.prototype.onDay = function(event) {
      this.begDay = parseInt(event.target.value);
      this.resetRooms();
    };

    Book.prototype.resetRooms = function() {
      $('#Rooms').empty();
      $('#Rooms').append(this.roomsHtml());
      return this.roomsJQuery();
    };

    Book.prototype.onPets = function(event) {
      this.pet = event.target.value;
      this.updatePrices();
    };

    Book.prototype.onTest = function() {
      return this.stream.publish("Alloc", Book.Alloc);
    };

    Book.prototype.onCellBook = function(event) {
      var $cell, date, roomId, status;
      $cell = $(event.target);
      status = $cell.attr('data-status');
      if (status === 'free') {
        status = 'mine';
      } else if (status === 'mine') {
        status = 'free';
      }
      this.cellStatus($cell, status);
      roomId = $cell.attr('id').substr(0, 1);
      date = $cell.attr('id').substr(1, 8);
      return this.updateTotal(roomId, date, status);
    };

    Book.prototype.onAlloc = function(alloc) {
      var bdays, book, cust, custId, day, i, len, lookup, ref, roomId;
      for (roomId in alloc) {
        if (!hasProp.call(alloc, roomId)) continue;
        book = alloc[roomId];
        for (custId in book) {
          if (!hasProp.call(book, custId)) continue;
          cust = book[custId];
          for (lookup in cust) {
            if (!hasProp.call(cust, lookup)) continue;
            bdays = cust[lookup];
            ref = cust.days;
            for (i = 0, len = ref.length; i < len; i++) {
              day = ref[i];
              this.allocCell(roomId, day, cust.status);
            }
          }
        }
      }
    };

    Book.prototype.allocCell = function(roomId, day, status) {
      return this.cellStatus($('#' + roomId + day), status);
    };

    Book.prototype.cellStatus = function($cell, status) {
      return $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    Book.prototype.dayMonth = function(iday) {
      var day;
      day = this.begDay + iday - 1;
      if (day > this.numDayMonth[this.monthIdx]) {
        return day - this.numDayMonth[this.monthIdx];
      } else {
        return day;
      }
    };

    Book.prototype.toDateStr = function(day) {
      return this.year + Util.pad(this.monthIdx + 5) + Util.pad(this.dayMonth(day));
    };

    return Book;

  })();

}).call(this);
