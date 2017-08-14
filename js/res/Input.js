// Generated by CoffeeScript 1.12.2
(function() {
  var $, Data, Input, UI;

  $ = require('jquery');

  Data = require('js/res/Data');

  UI = require('js/res/UI');

  Input = (function() {
    module.exports = Input;

    function Input(stream, store, res, master) {
      this.stream = stream;
      this.store = store;
      this.res = res;
      this.master = master;
      this.resv = {};
      this.state = 'add';
      this.lastResId = 'none';
    }

    Input.prototype.readyInput = function() {
      $('#ResAdd').empty();
      $('#ResAdd').append(this.html());
      $('#ResAdd').hide();
      return this.action();
    };

    Input.prototype.createResv = function(arrive, stayto, roomId) {
      var ref;
      ref = this.master.fillInCells(arrive, stayto, roomId, 'Free', 'Mine'), arrive = ref[0], stayto = ref[1];
      if (!((arrive != null) && (stayto != null))) {
        return;
      }
      this.resv = {};
      this.resv.arrive = arrive;
      this.resv.stayto = stayto;
      this.resv.depart = Data.advanceDate(stayto, 1);
      this.resv.roomId = roomId;
      this.resv.last = "";
      this.resv.status = 'Booking';
      this.resv.guests = 4;
      this.resv.pets = 0;
      this.resv.price = this.res.calcPrice(this.resv.roomId, this.resv.guests, this.resv.pets, this.resv.status);
      this.resv.booked = Data.today();
      this.state = 'add';
      this.refreshResv(this.resv);
    };

    Input.prototype.updateResv = function(arrive, stayto, roomId, resv) {
      var ref;
      ref = resv.resId !== this.lastResId ? [resv.arrive, resv.stayto] : [arrive, stayto], arrive = ref[0], stayto = ref[1];
      if (this.updateDates(arrive, stayto, roomId, resv)) {
        this.resv = resv;
        this.state = 'put';
        this.refreshResv(this.resv);
        this.lastResId = this.resv.resId;
      } else {
        alert("Reservation Dates Not Free: Arrive" + arrive + " StayTo:" + stayto + " RoomId:#" + roomId + " Name:" + resv.last);
      }
    };

    Input.prototype.updateDates = function(arrive, stayto, roomId, resv) {
      var beg, end, free;
      if (!((arrive != null) && (stayto != null) && (roomId != null))) {
        return false;
      }
      beg = Math.min(arrive, stayto).toString();
      end = Math.max(arrive, stayto).toString();
      if (beg != null) {
        resv.arrive = beg;
      }
      if (end != null) {
        resv.stayto = end;
      }
      free = this.res.datesFree(arrive, stayto, roomId, resv);
      return free;
    };

    Input.prototype.html = function() {
      var htm;
      htm = "<table id=\"NRTable\"><thead>";
      htm += "<tr><th>Arrive</th><th>Stay To</th><th>Room</th><th>Name</th>";
      htm += "<th>Guests</th><th>Pets</th><th>Status</th>";
      htm += "<th>Nights</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th><th>Action</th></tr>";
      htm += "</thead><tbody>";
      htm += "<tr><td>" + (this.arrive()) + "</td><td>" + (this.stayto()) + "</td><td>" + (this.rooms()) + "</td><td>" + (this.names()) + "</td>";
      htm += "<td>" + (this.guests()) + "</td><td>" + (this.pets()) + "</td><td>" + (this.status()) + "</td>";
      htm += "<td id=\"NRNights\"></td><td id=\"NRPrice\"></td><td id=\"NRTotal\"></td><td id=\"NRTax\"></td><td id=\"NRCharge\"></td>";
      htm += "<td id=\"NRSubmit\">" + (this.submit()) + "</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Input.prototype.action = function() {
      var onMMDD;
      onMMDD = (function(_this) {
        return function(htmlId, mmdd, klass) {
          var date, dd, mi, ref, roomId;
          ref = Data.midd(mmdd), mi = ref[0], dd = ref[1];
          date = Data.toDateStr(dd, mi);
          roomId = _this.resv.roomId;
          _this.master.fillCell(roomId, date, klass);
          if (htmlId === 'NRArrive') {
            _this.resv.arrive = date;
          }
          if (htmlId === 'NRStayTo') {
            _this.resv.stayto = date;
          }
          _this.refreshResv(_this.resv);
        };
      })(this);
      UI.onArrowsMMDD('NRArrive', onMMDD);
      UI.onArrowsMMDD('NRStayTo', onMMDD);
      $('#NRNames').change((function(_this) {
        return function(event) {
          _this.resv.last = event.target.value;
        };
      })(this));
      $('#NRRooms').change((function(_this) {
        return function(event) {
          _this.resv.roomId = event.target.value;
          _this.refreshResv(_this.resv);
        };
      })(this));
      $('#NRGuests').change((function(_this) {
        return function(event) {
          _this.resv.guests = event.target.value;
          _this.refreshResv(_this.resv);
        };
      })(this));
      $('#NRPets').change((function(_this) {
        return function(event) {
          _this.resv.pets = event.target.value;
          _this.refreshResv(_this.resv);
        };
      })(this));
      $('#NRStatus').change((function(_this) {
        return function(event) {
          _this.resv.status = event.target.value;
          _this.refreshResv(_this.resv);
        };
      })(this));
      return this.resvSubmits();
    };

    Input.prototype.arrive = function() {
      return UI.htmlArrows('NRArrive', 'NRArrive');
    };

    Input.prototype.stayto = function() {
      return UI.htmlArrows('NRStayTo', 'NRStayTo');
    };

    Input.prototype.rooms = function() {
      return UI.htmlSelect('NRRooms', this.res.roomKeys, this.resv.roomId);
    };

    Input.prototype.guests = function() {
      return UI.htmlSelect('NRGuests', Data.persons, 4);
    };

    Input.prototype.pets = function() {
      return UI.htmlSelect('NRPets', Data.pets, 0);
    };

    Input.prototype.status = function() {
      return UI.htmlSelect('NRStatus', Data.statusesSel, 'Skyline');
    };

    Input.prototype.names = function() {
      return UI.htmlInput('NRNames');
    };

    Input.prototype.submit = function() {
      var htm;
      htm = UI.htmlButton('NRCreate', 'NRSubmit', 'Create');
      htm += UI.htmlButton('NRChange', 'NRSubmit', 'Change');
      htm += UI.htmlButton('NRDelete', 'NRSubmit', 'Delete');
      return htm;
    };

    Input.prototype.refreshResv = function(resv) {
      resv.depart = Data.advanceDate(resv.stayto, 1);
      resv.nights = Data.nights(resv.arrive, resv.depart);
      resv.price = this.res.calcPrice(resv.roomId, resv.guests, resv.pets, resv.status);
      resv.deposit = resv.price * 0.5;
      resv.total = resv.nights * resv.price;
      resv.tax = parseFloat(Util.toFixed(resv.total * Data.tax));
      resv.charge = Util.toFixed(resv.total + resv.tax);
      $('#NRArrive').text(Data.toMMDD(resv.arrive));
      $('#NRStayTo').text(Data.toMMDD(resv.stayto));
      $('#NRNames').val(resv.last);
      $('#NRRooms').val(resv.roomId);
      $('#NRGuests').val(resv.guests);
      $('#NRPets').val(resv.pets);
      $('#NRStatus').val(resv.status);
      $('#NRNights').text(resv.nights);
      $('#NRPrice').text('$' + resv.price);
      $('#NRTotal').text('$' + resv.total);
      $('#NRTax').text('$' + resv.tax);
      $('#NRCharge').text('$' + resv.charge);
      this.master.setLast(resv.arrive, resv.roomId, resv.last);
      if (this.state === 'add') {
        $('#NRCreate').show();
        $('#NRChange').hide();
        $('#NRDelete').hide();
      } else if (this.state === 'put') {
        $('#NRCreate').hide();
        $('#NRChange').show();
        $('#NRDelete').show();
      }
    };

    Input.prototype.resvSubmits = function() {
      var doDel, doRes;
      doRes = (function(_this) {
        return function() {
          var r;
          r = _this.resv;
          if (r.status === 'Skyline' || 'Deposit') {
            r = _this.res.createResvSkyline(r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.pets);
          } else if (r.status === 'Booking' || 'Prepaid') {
            r = _this.res.createResvBooking(r.arrive, r.depart, r.roomId, r.last, r.status, r.guests, r.total, r.booked);
          } else {
            r = null;
            alert("Unknown Reservation Status: " + r.status + " Name:" + r.last);
          }
          _this.master.setLast(r.arrive, r.roomId, r.last);
          return r;
        };
      })(this);
      doDel = (function(_this) {
        return function() {
          _this.resv.status = 'Free';
          _this.resv.last = '';
          _this.res.deleteDaysFromResv(_this.resv);
          return _this.resv;
        };
      })(this);
      $('#NRCreate').click((function(_this) {
        return function() {
          var resv;
          if (Util.isStr(_this.resv.last)) {
            resv = doRes();
            if (resv != null) {
              _this.res.addResv(resv);
            }
          } else {
            alert('Incomplete Reservation');
          }
        };
      })(this));
      $('#NRChange').click((function(_this) {
        return function() {
          var resv;
          resv = doDel();
          resv = doRes();
          if (resv != null) {
            _this.res.putResv(resv);
          }
        };
      })(this));
      $('#NRDelete').click((function(_this) {
        return function() {
          var resv;
          resv = doDel();
          resv.status = 'Cancel';
          _this.res.delResv(resv);
        };
      })(this));
      return $('#NRCancel').click((function(_this) {
        return function() {
          var resv;
          resv = doRes();
          resv.status = 'Cancel';
          if (resv != null) {
            _this.res.canResv(resv);
          }
        };
      })(this));
    };

    return Input;

  })();

}).call(this);
