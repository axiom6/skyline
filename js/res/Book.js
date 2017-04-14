// Generated by CoffeeScript 1.12.2
(function() {
  var $, Alloc, Book,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Alloc = require('js/res/Alloc');

  Book = (function() {
    module.exports = Book;

    function Book(stream, store, room1, cust, res1, pay, pict, Data) {
      this.stream = stream;
      this.store = store;
      this.room = room1;
      this.cust = cust;
      this.res = res1;
      this.pay = pay;
      this.pict = pict;
      this.Data = Data;
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
      this.totals = 0;
      this.method = 'site';
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

    Book.prototype.isValid = function(name, test) {
      var valid, value;
      value = $('#' + name).val();
      valid = Util.isStr(value);
      if (this.Data.testing && !valid) {
        value = test;
      }
      if (this.Data.testing) {
        valid = true;
      }
      if (!valid) {
        $('#' + name + 'ER').show();
      }
      return [value, valid];
    };

    Book.prototype.getNamesPhoneEmail = function() {
      var ev, fv, lv, ok, pv, ref, ref1, ref2, ref3;
      ref = this.isValid('First', 'Samuel'), this.pay.first = ref[0], fv = ref[1];
      ref1 = this.isValid('Last', 'Hosendecker'), this.pay.last = ref1[0], lv = ref1[1];
      ref2 = this.isValid('Phone', '3037977129'), this.pay.phone = ref2[0], pv = ref2[1];
      ref3 = this.isValid('EMail', 'Thomas.Edmund.Flaherty@gmail.com'), this.pay.email = ref3[0], ev = ref3[1];
      ok = this.totals > 0 && fv && lv && pv && ev;
      Util.log('Book.getNamesPhoneEmail()', this.pay.first, fv, this.pay.last, lv, this.pay.phone, pv, this.pay.email, ev, ok);
      return this.totals > 0 && fv && lv && pv && ev;
    };

    Book.prototype.onGoToPay = function(e) {
      var ok, res;
      e.preventDefault();
      ok = this.getNamesPhoneEmail();
      if (ok) {
        $('.NameER').hide();
        $('#Book').hide();
        res = this.createRes();
        res.total = this.totals;
        this.pay.showConfirmPay(res);
      } else {
        alert('Correct Errors');
      }
    };

    new ({
      createCell: function(roomId, room, date) {
        var status;
        status = this.room.dayBooked(room, date);
        return "<td id=\"R" + (roomId + date) + "\" class=\"room-" + status + "\" data-status=\"" + status + "\"></td>";
      },
      roomsJQuery: function() {
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
      },
      calcPrice: function(roomId) {
        var guests, pets, price, roomUI;
        roomUI = Book.roomUIs[roomId];
        guests = roomUI.resRoom.guests;
        pets = roomUI.resRoom.pets;
        price = Book.rooms[roomId][guests] + pets * Book.Data.petPrice;
        roomUI.resRoom.price = price;
        return price;
      },
      updatePrice: function(roomId) {
        $('#' + roomId + 'M').text("" + ('$' + Book.calcPrice(roomId)));
        Book.updateTotal(roomId);
      },
      updateTotal: function(roomId) {
        var price, room, text;
        price = this.calcPrice(roomId);
        room = this.roomUIs[roomId];
        room.resRoom.total = price * room.numDays;
        text = room.resRoom.total === 0 ? '' : '$' + room.resRoom.total;
        $('#' + roomId + 'T').text(text);
        this.updateTotals();
      },
      newCust: function() {
        return {
          status: 'mine',
          days: [],
          total: 0
        };
      },
      updateTotals: function() {
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
      },
      toDay: function(date) {
        if (date.charAt(6) === '0') {
          return date.substr(7, 8);
        } else {
          return date.substr(6, 8);
        }
      },
      g: function(roomId) {
        return this.htmlSelect(roomId + 'G', this.Data.persons, 2, 'guests', this.rooms[roomId].max);
      },
      p: function(roomId) {
        return this.htmlSelect(roomId + 'P', this.Data.pets, 0, 'pets', 3);
      },
      htmlSelect: function(htmlId, array, choice, klass, max) {
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
      },
      onGuests: function(event) {
        var roomId;
        roomId = $(event.target).attr('id').charAt(0);
        Book.roomUIs[roomId].resRoom.guests = event.target.value;
        Util.log('Book.onGuests', roomId, Book.roomUIs[roomId].guests, Book.calcPrice(roomId));
        Book.updatePrice(roomId);
      },
      onPets: function(event) {
        var roomId;
        roomId = $(event.target).attr('id').charAt(0);
        Book.roomUIs[roomId].resRoom.pets = event.target.value;
        Util.log('Book.onPets', roomId, Book.roomUIs[roomId].pets, Book.calcPrice(roomId));
        Book.updatePrice(roomId);
      },
      onMonth: function(event) {
        Book.month = event.target.value;
        Book.monthIdx = Book.Data.months.indexOf(Book.month);
        Book.begDay = Book.month === 'May' ? Book.begMay : 1;
        $('#Days').val(Book.begDay.toString());
        Util.log('Book.onMonth()', {
          monthIdx: Book.monthIdx,
          month: Book.month,
          begDay: Book.begDay
        });
        Book.resetRooms();
      },
      onDay: function(event) {
        Book.begDay = parseInt(event.target.value);
        if (Book.month === 'October' && Book.begDay > 1) {
          Book.begDay = 1;
          alert('The Season Ends on October 15');
        } else {
          Book.resetRooms();
        }
      },
      resetRooms: function() {
        $('#Rooms').empty();
        $('#Rooms').append(this.roomsHtml(this.year, this.monthIdx, this.begDay, this.numDays));
        return this.roomsJQuery();
      },
      onTest: function() {
        Util.log('Book.onTest()');
        return Book.store.insert('Alloc', Alloc.Allocs);
      },
      createRes: function() {
        var onAdd, ref, res, room, roomId;
        res = Book.res.createRes(Book.totals, 'hold', Book.method, Book.pay.phone, Book.roomUIs, {});
        res.payments = {};
        Book.res.add(res.id, res);
        Util.log('Book.createRes()', res);
        ref = res.rooms;
        for (roomId in ref) {
          if (!hasProp.call(ref, roomId)) continue;
          room = ref[roomId];
          onAdd = {};
          onAdd.days = room.days;
          Book.store.add('Alloc', roomId, onAdd);
        }
        return res;
      },

      /*
      onBook:() =>
        res = @createRes()
        res.payments      = {}
        res.payments['1'] = @res.resPay()
        #@res.put( res.id, res )
        for own roomId, room of res.rooms
          day.status = 'book' for own date, day of room.days
          onPut = {}
          onPut.days = room.days
          @store.put( 'Alloc', roomId, onPut )
        Util.log( 'Book.onBook()', res )
        return
       */
      onCellBook: function(event) {
        var $cell, date, roomId, roomUI, status;
        $cell = $(event.target);
        status = $cell.attr('data-status');
        if (status === 'free') {
          status = 'mine';
        } else if (status === 'mine') {
          status = 'free';
        }
        Book.cellStatus($cell, status);
        roomId = $cell.attr('id').substr(1, 1);
        date = $cell.attr('id').substr(2, 8);
        roomUI = Book.roomUIs[roomId];
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
        return Book.updateTotal(roomId);
      },
      onAlloc: function(alloc, roomId) {
        var day, obj, ref;
        ref = alloc.days;
        for (day in ref) {
          if (!hasProp.call(ref, day)) continue;
          obj = ref[day];
          Book.allocCell(day, obj.status, roomId);
        }
      },
      allocCell: function(day, status, roomId) {
        return this.cellStatus($('#R' + roomId + day), status);
      },
      cellStatus: function($cell, status) {
        return $cell.removeClass().addClass("room-" + status).attr('data-status', status);
      },
      dayMonth: function(day) {
        var monthDay;
        monthDay = day + this.begDay - 1;
        if (monthDay > this.Data.numDayMonth[this.monthIdx]) {
          return monthDay - this.Data.numDayMonth[this.monthIdx];
        } else {
          return monthDay;
        }
      },
      toDateStr: function(day) {
        return this.year + Util.pad(this.monthIdx + 1) + Util.pad(this.dayMonth(day, this.begDay));
      },
      make: function() {
        return Book.store.make('Room');
      },
      insert: function() {
        return Book.store.insert('Room', Book.rooms);
      }

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
    });

    return Book;

  })();

}).call(this);
