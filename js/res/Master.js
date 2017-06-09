// Generated by CoffeeScript 1.12.2
(function() {
  var $, Master,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Master = (function() {
    module.exports = Master;

    function Master(stream, store, Data, res, pay) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.pay = pay;
      this.onUpdateRes = bind(this.onUpdateRes, this);
      this.onSeasonClick = bind(this.onSeasonClick, this);
      this.onMasterClick = bind(this.onMasterClick, this);
      this.onAlloc = bind(this.onAlloc, this);
      this.listenToResv = bind(this.listenToResv, this);
      this.selectToDays = bind(this.selectToDays, this);
      this.listenToDays = bind(this.listenToDays, this);
      this.onDateRange = bind(this.onDateRange, this);
      this.readyMaster = bind(this.readyMaster, this);
      this.onUploadBtn = bind(this.onUploadBtn, this);
      this.onDailysBtn = bind(this.onDailysBtn, this);
      this.onSeasonBtn = bind(this.onSeasonBtn, this);
      this.onLookup = bind(this.onLookup, this);
      this.onMasterBtn = bind(this.onMasterBtn, this);
      this.rooms = this.res.rooms;
      this.uploadedText = "";
      this.uploadedResvs = {};
      this.res.master = this;
      this.lastMaster = {
        left: 0,
        top: 0,
        width: 0,
        height: 0
      };
      this.lastSeason = {
        left: 0,
        top: 0,
        width: 0,
        height: 0
      };
    }

    Master.prototype.ready = function() {
      this.listenToDays();
      $('#MasterBtn').click(this.onMasterBtn);
      $('#SeasonBtn').click(this.onSeasonBtn);
      $('#DailysBtn').click(this.onDailysBtn);
      $('#UploadBtn').click(this.onUploadBtn);
      this.res.dateRange(this.Data.beg, this.Data.end, this.readyMaster);
    };

    Master.prototype.onMasterBtn = function() {
      $('#Lookup').hide();
      $('#Season').hide();
      $('#Dailys').hide();
      $('#Upload').hide();
      $('#Master').show();
    };

    Master.prototype.onLookup = function(resv) {
      $('#Master').hide();
      $('#Season').hide();
      $('#Dailys').hide();
      $('#Upload').hide();
      $('#Lookup').empty();
      Util.log('Master.onLookup', resv);
      if (!Util.isObjEmpty(resv)) {
        $('#Lookup').append(this.pay.confirmHead(resv));
      }
      if (!Util.isObjEmpty(resv)) {
        $('#Lookup').append(this.pay.confirmTable(resv, 'Owner'));
      }
      $('#Lookup').show();
    };

    Master.prototype.onSeasonBtn = function() {
      $('#Master').hide();
      $('#Lookup').hide();
      $('#Dailys').hide();
      $('#Upload').hide();
      if (Util.isEmpty($('#Season').children())) {
        $('#Season').append(this.seasonHtml());
      }
      $('.SeasonTitle').click((function(_this) {
        return function(event) {
          return _this.onSeasonClick(event);
        };
      })(this));
      $('#Season').show();
    };

    Master.prototype.onDailysBtn = function() {
      $('#Master').hide();
      $('#Lookup').hide();
      $('#Season').hide();
      $('#Upload').hide();
      if (Util.isEmpty($('#Dailys').children())) {
        $('#Dailys').append(this.dailysHtml());
      }
      $('#Dailys').show();
    };

    Master.prototype.onUploadBtn = function() {
      $('#Master').hide();
      $('#Lookup').hide();
      $('#Season').hide();
      $('#Dailys').hide();
      if (Util.isEmpty($('#Upload').children())) {
        $('#Upload').append(this.uploadHtml());
      }
      this.bindUploadPaste();
      $('#UpdateRes').click(this.onUpdateRes);
      $('#Upload').show();
    };

    Master.prototype.readyMaster = function() {
      $('#Master').append(this.masterHtml());
      $('.MasterTitle').click((function(_this) {
        return function(event) {
          return _this.onMasterClick(event);
        };
      })(this));
      this.readyCells();
    };

    Master.prototype.readyCells = function() {
      var doCell;
      doCell = (function(_this) {
        return function(event) {
          var $cell, resId, status;
          $cell = $(event.target);
          status = $cell.attr('data-status');
          resId = $cell.attr('data-res');
          Util.log('doCell', {
            resId: resId,
            status: status
          });
          if (status !== 'free') {
            _this.res.onResId('get', _this.onLookup, resId);
            return _this.store.get('Res', resId);
          }
        };
      })(this);
      $('[data-cell="y"]').click(doCell);
    };

    Master.prototype.onDateRange = function() {
      var dayId, dayRoom, ref;
      this.readyMaster();
      ref = this.res.days;
      for (dayId in ref) {
        if (!hasProp.call(ref, dayId)) continue;
        dayRoom = ref[dayId];
        this.onAlloc(dayId, dayRoom);
      }
    };

    Master.prototype.listenToDays = function() {
      var doDays;
      doDays = (function(_this) {
        return function(data) {
          console.log('Master.listenToDays()', data.key, data.val);
          return _this.onAlloc(data.key, data.val);
        };
      })(this);
      this.res.onDays('put', doDays);
    };

    Master.prototype.selectToDays = function() {
      var doDays;
      doDays = (function(_this) {
        return function(days) {
          var day, dayId, results;
          console.log('Master.selectDays()', days);
          results = [];
          for (dayId in days) {
            if (!hasProp.call(days, dayId)) continue;
            day = days[dayId];
            results.push(_this.onAlloc(dayId, day));
          }
          return results;
        };
      })(this);
      this.res.onDays('select', doDays);
      this.store.select('Days');
    };

    Master.prototype.listenToResv = function() {
      var doAdd;
      doAdd = (function(_this) {
        return function(onAdd) {
          var dayId, rday, ref, results, resv, room, roomId;
          resv = onAdd.val;
          Util.log('Master.listenToResv() onAdd', resv);
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
                rday = ref1[dayId];
                results1.push(this.onAlloc(dayId, rday));
              }
              return results1;
            }).call(_this));
          }
          return results;
        };
      })(this);
      this.res.onResv('add', doAdd);
    };

    Master.prototype.onAlloc = function(dayId, dayRoom) {
      var room, roomId;
      for (roomId in dayRoom) {
        if (!hasProp.call(dayRoom, roomId)) continue;
        room = dayRoom[roomId];
        this.allocMasterCell(roomId, dayId, room.status);
        this.allocSeasonCell(roomId, dayId, room.status);
      }
    };

    Master.prototype.cellId = function(pre, date, roomId) {
      return pre + date + roomId;
    };

    Master.prototype.$cell = function(pre, date, roomId) {
      return $('#' + this.cellId(pre, date, roomId));
    };

    Master.prototype.createMasterCell = function(roomId, date) {
      var resId, status;
      status = this.res.getStatus(roomId, date);
      resId = this.res.resId(roomId, date);
      return "<td id=\"" + (this.cellId('M', date, roomId)) + "\" class=\"room-" + status + "\" data-status=\"" + status + "\" data-res=\"" + resId + "\" data-cell=\"y\"></td>";
    };

    Master.prototype.allocMasterCell = function(roomId, date, status) {
      this.cellMasterStatus(this.$cell('M', date, roomId), status);
    };

    Master.prototype.allocSeasonCell = function(roomId, date, status) {
      this.cellSeasonStatus(this.$cell('S', date, roomId), status);
    };

    Master.prototype.cellMasterStatus = function($cell, status) {
      $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    Master.prototype.cellSeasonStatus = function($cell, status) {
      $cell.removeClass().addClass("own-" + status).attr('data-status', status);
    };

    Master.prototype.onMasterClick = function(event) {
      var $master, $month, $title;
      $title = $(event.target);
      $month = $title.parent();
      $master = $('#Master');
      if (this.lastMaster.height === 0) {
        $master.children().hide();
        this.lastMaster = {
          left: $month.css('left'),
          top: $month.css('top'),
          width: $month.css('width'),
          height: $month.css('height')
        };
        $month.css({
          left: 0,
          top: 0,
          width: '100%',
          height: '450px'
        }).show();
      } else {
        $month.css(this.lastMaster);
        $master.children().show();
        this.lastMaster.height = 0;
      }
    };

    Master.prototype.onSeasonClick = function(event) {
      var $month, $season, $title;
      $title = $(event.target);
      $month = $title.parent();
      $season = $('#Season');
      if (this.lastSeason.height === 0) {
        $season.children().hide();
        this.lastSeason = {
          left: $month.css('left'),
          top: $month.css('top'),
          width: $month.css('width'),
          height: $month.css('height')
        };
        $month.css({
          left: 0,
          top: 0,
          width: '100%',
          height: '450px'
        }).show();
      } else {
        $month.css(this.lastSeason);
        $season.children().show();
        this.lastSeason.height = 0;
      }
    };

    Master.prototype.masterHtml = function() {
      var htm, i, len, month, ref;
      htm = "";
      ref = this.Data.season;
      for (i = 0, len = ref.length; i < len; i++) {
        month = ref[i];
        htm += "<div id=\"" + month + "\" class=\"" + month + "\">" + (this.roomsHtml(this.Data.year, month)) + "</div>";
      }
      return htm;
    };

    Master.prototype.roomsHtml = function(year, month) {
      var begDay, date, day, endDay, htm, i, j, k, monthIdx, ref, ref1, ref2, ref3, ref4, ref5, ref6, room, roomId, weekday, weekdayIdx;
      monthIdx = this.Data.months.indexOf(month);
      begDay = 1;
      endDay = this.Data.numDayMonth[monthIdx];
      weekdayIdx = new Date(2000 + year, monthIdx, 1).getDay();
      htm = "<div class=\"MasterTitle\">" + month + "</div>";
      htm += "<table><thead>";
      htm += "<tr><th></th>";
      for (day = i = ref = begDay, ref1 = endDay; ref <= ref1 ? i <= ref1 : i >= ref1; day = ref <= ref1 ? ++i : --i) {
        weekday = this.Data.weekdays[(weekdayIdx + day - 1) % 7].charAt(0);
        htm += "<th>" + weekday + "</th>";
      }
      htm += "</tr><tr><th></th>";
      for (day = j = ref2 = begDay, ref3 = endDay; ref2 <= ref3 ? j <= ref3 : j >= ref3; day = ref2 <= ref3 ? ++j : --j) {
        htm += "<th>" + day + "</th>";
      }
      htm += "</tr></thead><tbody>";
      ref4 = this.rooms;
      for (roomId in ref4) {
        if (!hasProp.call(ref4, roomId)) continue;
        room = ref4[roomId];
        htm += "<tr id=\"" + roomId + "\"><td>" + roomId + "</td>";
        for (day = k = ref5 = begDay, ref6 = endDay; ref5 <= ref6 ? k <= ref6 : k >= ref6; day = ref5 <= ref6 ? ++k : --k) {
          date = this.Data.toDateStr(day, monthIdx);
          htm += this.createMasterCell(roomId, date);
        }
        htm += "</tr>";
      }
      htm += "</tbody></table>";
      return htm;
    };

    Master.prototype.seasonHtml = function() {
      var htm, i, len, month, ref;
      htm = "";
      ref = this.Data.season;
      for (i = 0, len = ref.length; i < len; i++) {
        month = ref[i];
        htm += "<div id=\"" + month + "\" class=\"" + month + "C\">" + (this.monthTable(month)) + "</div>";
      }
      return htm;
    };

    Master.prototype.monthTable = function(month) {
      var begDay, col, day, endDay, htm, i, j, k, monthIdx, row, weekday;
      monthIdx = this.Data.months.indexOf(month);
      begDay = new Date(2000 + this.res.year, monthIdx, 1).getDay() - 1;
      endDay = this.Data.numDayMonth[monthIdx];
      htm = "<div class=\"SeasonTitle\">" + month + "</div>";
      htm += "<table class=\"MonthTable\"><thead><tr>";
      for (day = i = 0; i < 7; day = ++i) {
        weekday = this.Data.weekdays[day];
        htm += "<th>" + weekday + "</th>";
      }
      htm += "</tr></thead><tbody>";
      for (row = j = 0; j < 6; row = ++j) {
        htm += "<tr>";
        for (col = k = 0; k < 7; col = ++k) {
          day = this.monthDay(begDay, endDay, row, col);
          htm += day !== "" ? "<td>" + (this.roomDay(monthIdx, day)) + "</td>" : "<td></td>";
        }
        htm += "</tr>";
      }
      return htm += "</tbody></table>";
    };

    Master.prototype.roomDay = function(monthIdx, day) {
      var col, date, htm, i, roomId, status;
      htm = "";
      htm += "<div class=\"MonthDay\">" + day + "</div>";
      htm += "<div class=\"MonthRoom\">";
      for (col = i = 1; i <= 10; col = ++i) {
        roomId = col;
        if (roomId === 9) {
          roomId = 'N';
        }
        if (roomId === 10) {
          roomId = 'S';
        }
        date = this.Data.toDateStr(day, monthIdx);
        status = this.res.getStatus(roomId, date);
        if (status !== 'free') {
          htm += "<span id=\"" + (this.roomDayId(monthIdx, day, roomId)) + "\" class=\"own-" + status + "\">" + roomId + " data-res=\"y\"</span>";
        }
      }
      htm += "</div>";
      return htm;
    };

    Master.prototype.roomDayId = function(monthIdx, day, roomId) {
      var date;
      date = this.Data.dateStr(day, monthIdx);
      return this.cellId('S', roomId, date);
    };

    Master.prototype.monthDay = function(begDay, endDay, row, col) {
      var day;
      day = row * 7 + col - begDay;
      day = 1 <= day && day <= endDay ? day : "";
      return day;
    };

    Master.prototype.dailysHtml = function() {
      var htm;
      htm = "";
      htm += "<h1 class=\"DailysH1\">Daily Activities</h1>";
      htm += "<h2 class=\"DailysH2\">Arrivals</h2>";
      htm += "<h2 class=\"DailysH2\">Departures</h2>";
      return htm;
    };

    Master.prototype.uploadHtml = function() {
      var htm;
      htm = "";
      htm += "<h1 class=\"UploadH1\">Upload Booking.com</h1>";
      htm += "<button id=\"UpdateRes\" class=\"btn btn-primary\">Update Res</button>";
      htm += "<textarea id=\"UploadText\" class=\"UploadText\" rows=\"50\" cols=\"100\"></textarea>";
      return htm;
    };

    Master.prototype.bindUploadPaste = function() {
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
            Util.log('Master.onPaste()');
            Util.log(_this.uploadedText);
            _this.uploadedResvs = _this.uploadParse(_this.uploadedText);
            return $('#UploadText').text(_this.uploadedText);
          }
        };
      })(this);
      return document.addEventListener("paste", onPaste);
    };

    Master.prototype.uploadParse = function(text) {
      var book, i, len, line, lines, namesg, obj, resv, toks;
      obj = {};
      if (!Util.isStr(text)) {
        return obj;
      }
      lines = text.split('\n');
      for (i = 0, len = lines.length; i < len; i++) {
        line = lines[i];
        toks = line.split('\t');
        book = {};
        resv = {};
        book.nameg = toks[0];
        book.arrive = toks[1];
        book.depart = toks[2];
        book.room = toks[3];
        book.booked = toks[4];
        book.status = toks[5];
        book.total = toks[6];
        book.commis = toks[7];
        book.bookingId = toks[8];
        namesg = book.nameg.split(' ');
        resv.first = namesg[0];
        resv.last = namesg[1];
        resv.guests = namesg[2].charAt(0);
        resv.arrive = this.toResvDate(book.arrive);
        resv.depart = this.toResvDate(book.depart);
        resv.pets = 0;
        resv.spa = false;
        resv.nights = this.Data.nights(resv.arrive, resv.depart);
        resv.roomId = this.toResvRoomId(book.room);
        resv.id = resv.arrive + resv.roomId;
        obj[resv.id] = resv;
        Util.log('Book......');
        Util.log(book);
        Util.log('Resv......');
        Util.log(resv);
      }
      return obj;
    };

    Master.prototype.onUpdateRes = function() {
      var resId, resv, resvs;
      if (Util.isObjEmpty(this.uploadedResvs)) {
        return;
      }
      resvs = this.updateResv(this.uploadedResvs);
      this.res.days = this.res.createDaysFromResvs(resvs, this.res.days);
      for (resId in resvs) {
        if (!hasProp.call(resvs, resId)) continue;
        resv = resvs[resId];
        this.res.postResvChan(resv);
      }
      return this.uploadedResv = {};
    };

    Master.prototype.updateResv = function(uploadedResvs) {
      var cust, days, resId, resv, resvs, rooms, u;
      resvs = {};
      for (resId in uploadedResvs) {
        if (!hasProp.call(uploadedResvs, resId)) continue;
        u = uploadedResvs[resId];
        rooms = {};
        cust = this.res.createCust(u.first, u.last, "", "", "Booking");
        days = this.res.createRoomDays(u.arrive, u.depart, 'chan', u.id);
        rooms[u.roomId] = this.populateRoom({}, days, u.total, u.total / u.nights, u.guests, 0);
        resv = this.res.createRoomResv('chan', 'vcard', u.total, cust, rooms);
        resvs[resId] = resv;
      }
      return resvs;
    };

    Master.prototype.toResvDate = function(bookDate) {
      var day, month, toks, year;
      toks = bookDate.split(' ');
      year = this.Data.year;
      month = this.Data.months.indexOf(toks[1]) + 1;
      day = toks[0];
      return year.toString() + Util.pad(month) + day;
    };

    Master.prototype.toResvRoomId = function(bookRoom) {
      var toks;
      toks = bookRoom.split(' ');
      if (toks[0].charAt(0) === '#') {
        return toks[0].charAt(1);
      } else {
        return toks[2].charAt(0);
      }
    };

    Master.prototype.uploadTable = function() {};

    return Master;

  })();

}).call(this);
