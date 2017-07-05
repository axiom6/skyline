// Generated by CoffeeScript 1.12.2
(function() {
  var $, Upload,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Upload = (function() {
    module.exports = Upload;

    function Upload(stream, store, Data, res) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.onCustomFix = bind(this.onCustomFix, this);
      this.onCreateCan = bind(this.onCreateCan, this);
      this.onCreateDay = bind(this.onCreateDay, this);
      this.onCreateRes = bind(this.onCreateRes, this);
      this.onUploadCan = bind(this.onUploadCan, this);
      this.onUploadRes = bind(this.onUploadRes, this);
      this.uploadedText = "";
      this.uploadedResvs = {};
    }

    Upload.prototype.html = function() {
      var htm;
      htm = "";
      htm += "<h1  class=\"UploadH1\">Upload Booking.com</h1>";
      htm += "<button id=\"UploadRes\" class=\"btn btn-primary\">Upload Res</button>";
      htm += "<button id=\"UploadCan\" class=\"btn btn-primary\">Upload Can</button>";
      htm += "<button id=\"CustomFix\" class=\"btn btn-primary\">Custom Fix</button>";
      htm += "<textarea id=\"UploadText\" class=\"UploadText\" rows=\"50\" cols=\"100\"></textarea>";
      return htm;
    };

    Upload.prototype.bindUploadPaste = function() {
      var onPaste;
      onPaste = (function(_this) {
        return function(event) {
          if (window.clipboardData && window.clipboardData.getData) {
            _this.uploadedText = window.clipboardData.getData('Text');
          } else if (event.clipboardData && event.clipboardData.getData) {
            _this.uploadedText = event.clipboardData.getData('text/plain');
          }
          event.preventDefault();
          if (Util.isStr(_this.uploadedText)) {
            _this.uploadedResvs = _this.uploadParse(_this.uploadedText);
            return $('#UploadText').text(_this.uploadedText);
          }
        };
      })(this);
      return document.addEventListener("paste", onPaste);
    };

    Upload.prototype.uploadParse = function(text) {
      var book, j, len, line, lines, resv, resvs, toks;
      resvs = {};
      if (!Util.isStr(text)) {
        return resvs;
      }
      lines = text.split('\n');
      for (j = 0, len = lines.length; j < len; j++) {
        line = lines[j];
        toks = line.split('\t');
        if (toks[0] === 'Guest name') {
          continue;
        }
        book = this.bookFromToks(toks);
        resv = this.resvFromBook(book);
        resvs[resv.resId] = resv;
      }
      return resvs;
    };

    Upload.prototype.bookFromToks = function(toks) {
      var book;
      book = {};
      book.names = toks[0];
      book.arrive = toks[1];
      book.depart = toks[2];
      book.room = toks[3];
      book.booked = toks[4];
      book.status = toks[5];
      book.total = toks[6];
      book.commis = toks[7];
      book.bookingId = toks[8];
      return book;
    };

    Upload.prototype.resvFromBook = function(book) {
      var arrive, booked, depart, guests, last, names, roomId, status, total;
      names = book.names.split(' ');
      arrive = this.toResvDate(book.arrive);
      depart = this.toResvDate(book.depart);
      booked = this.toResvDate(book.booked);
      roomId = this.toResvRoomId(book.room);
      last = names[1];
      status = this.toStatus(book.status);
      guests = this.toNumGuests(names);
      total = parseFloat(book.total.substr(3));
      return this.res.createResvBooking(arrive, depart, roomId, last, status, guests, total, booked);
    };

    Upload.prototype.onUploadRes = function() {
      Util.log('Upload.onUploadRes');
      if (!Util.isStr(this.uploadedText)) {
        this.uploadedText = this.Data.bookingResvs;
        this.uploadedResvs = this.uploadParse(this.uploadedText);
        $('#UploadText').text(this.uploadedText);
      }
      if (Util.isObjEmpty(this.uploadedResvs)) {
        return;
      }
      if (!this.updateValid(this.uploadedResvs)) {
        return;
      }
      this.res.updateResvs(this.uploadedResvs);
      return this.uploadedResvs = {};
    };

    Upload.prototype.onUploadCan = function() {
      Util.log('Upload.onUploadCan');
      if (!Util.isStr(this.uploadedText)) {
        this.uploadedText = this.Data.canceled;
        this.uploadedResvs = this.uploadParse(this.uploadedText);
        $('#UploadText').text(this.uploadedText);
      }
      if (Util.isObjEmpty(this.uploadedResvs)) {
        return;
      }
      if (!this.updateValid(this.uploadedResvs)) {
        return;
      }
      this.res.updateCancels(this.uploadedResvs);
      return this.uploadedResvs = {};
    };

    Upload.prototype.onCreateRes = function() {
      var ref, resId, resv, resvs;
      Util.log('Upload.onCreateRes');
      ref = this.res.resvs;
      for (resId in ref) {
        if (!hasProp.call(ref, resId)) continue;
        resv = ref[resId];
        this.res.delResv(resv);
      }
      resvs = require('data/res.json');
      for (resId in resvs) {
        if (!hasProp.call(resvs, resId)) continue;
        resv = resvs[resId];
        this.res.addResv(resv);
      }
    };

    Upload.prototype.onCreateDay = function() {
      var day, dayId, ref, ref1, resId, resv;
      Util.log('Upload.onCreateDay');
      ref = this.res.days;
      for (dayId in ref) {
        if (!hasProp.call(ref, dayId)) continue;
        day = ref[dayId];
        this.res.delDay(day);
      }
      ref1 = this.res.resvs;
      for (resId in ref1) {
        if (!hasProp.call(ref1, resId)) continue;
        resv = ref1[resId];
        this.res.updateDaysFromResv(resv);
      }
    };

    Upload.prototype.onCreateCan = function() {
      var can, canId, cans;
      Util.log('Upload.onCreateCan');
      cans = require('data/can.json');
      for (canId in cans) {
        if (!hasProp.call(cans, canId)) continue;
        can = cans[canId];
        this.res.addCan(can);
      }
    };

    Upload.prototype.onCustomFix = function() {};

    Upload.prototype.updateValid = function(uploadedResvs) {
      var resId, u, v, valid;
      valid = true;
      for (resId in uploadedResvs) {
        if (!hasProp.call(uploadedResvs, resId)) continue;
        u = uploadedResvs[resId];
        v = true;
        v &= Util.isStr(u.last);
        v &= 1 <= u.guests && u.guests <= 12;
        v &= this.Data.isDate(u.arrive);
        v &= this.Data.isDate(u.depart);
        v &= typeof pets === 'number' ? 0 <= u.pets && u.pets <= 4 : true;
        v &= 0 <= u.nights && u.nights <= 28;
        v &= Util.inArray(this.res.roomKeys, u.roomId);
        v &= 0.00 <= u.total && u.total <= 8820.00;
        v &= 120.00 <= u.price && u.price <= 315.00;
        valid &= v;
        if (!v) {
          Util.log('Resv Not Valid', resId, v);
          Util.log(u);
        }
      }
      Util.log('Master.updateValid()', valid);
      return true;
    };

    Upload.prototype.toNumGuests = function(names) {
      var i, j, ref;
      for (i = j = 0, ref = names.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        if (names[i] === 'guest' || names[i] === 'guests') {
          return names[i - 1];
        }
      }
      return '0';
    };

    Upload.prototype.toResvDate = function(bookDate) {
      var day, month, toks, year;
      toks = bookDate.split(' ');
      year = this.Data.year;
      month = this.Data.months.indexOf(toks[1]) + 1;
      day = toks[0];
      return year.toString() + Util.pad(month) + day;
    };

    Upload.prototype.toResvRoomId = function(bookRoom) {
      var toks;
      toks = bookRoom.split(' ');
      if (toks[0].charAt(0) === '#') {
        return toks[0].charAt(1);
      } else {
        return toks[2].charAt(0);
      }
    };

    Upload.prototype.toStatus = function(bookingStatus) {
      switch (bookingStatus) {
        case 'OK':
          return 'Booking';
        case 'Canceled':
          return 'Cancel';
        default:
          return 'Unknown';
      }
    };

    return Upload;

  })();

}).call(this);
