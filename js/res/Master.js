// Generated by CoffeeScript 1.12.2
(function() {
  var $, Input, Master, Query, Season, Upload,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Upload = require('js/res/Upload');

  Query = require('js/res/Query');

  Input = require('js/res/Input');

  Season = require('js/res/Season');

  Master = (function() {
    module.exports = Master;

    function Master(stream, store, Data, res) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.onMonthClick = bind(this.onMonthClick, this);
      this.onAlloc = bind(this.onAlloc, this);
      this.allocDays = bind(this.allocDays, this);
      this.selectToDays = bind(this.selectToDays, this);
      this.listenToResv = bind(this.listenToResv, this);
      this.listenToDays = bind(this.listenToDays, this);
      this.readyCells = bind(this.readyCells, this);
      this.readyMaster = bind(this.readyMaster, this);
      this.onUploadBtn = bind(this.onUploadBtn, this);
      this.onDailysBtn = bind(this.onDailysBtn, this);
      this.onSeasonBtn = bind(this.onSeasonBtn, this);
      this.onMakResBtn = bind(this.onMakResBtn, this);
      this.onMasterBtn = bind(this.onMasterBtn, this);
      this.rooms = this.res.rooms;
      this.upload = new Upload(this.stream, this.store, this.Data, this.res);
      this.query = new Query(this.stream, this.store, this.Data, this.res);
      this.input = new Input(this.stream, this.store, this.Data, this.res);
      this.season = new Season(this.stream, this.store, this.Data, this.res);
      this.res.master = this;
      this.dateBeg = this.Data.today();
      this.dateEnd = this.Data.today();
      this.fillBeg = null;
      this.fillEnd = null;
      this.fillRoomId = null;
      this.resMode = 'Table';
      this.roomId = null;
      this.showingMonth = 'Master';
    }

    Master.prototype.ready = function() {
      this.listenToDays();
      $('#MasterBtn').click(this.onMasterBtn);
      $('#MakResBtn').click(this.onMakResBtn);
      $('#SeasonBtn').click(this.onSeasonBtn);
      $('#DailysBtn').click(this.onDailysBtn);
      $('#UploadBtn').click(this.onUploadBtn);
      this.res.selectAllDays(this.readyMaster);
    };

    Master.prototype.onMasterBtn = function() {
      this.resMode = 'Table';
      $('#Season').hide();
      $('#Dailys').hide();
      $('#Upload').hide();
      $('#ResAdd').hide();
      $('#ResTbl').show();
      $('#Master').show();
    };

    Master.prototype.onMakResBtn = function() {
      var ref;
      this.resMode = 'Input';
      $('#Season').hide();
      $('#Dailys').hide();
      $('#Upload').hide();
      $('#ResAdd').show();
      $('#ResTbl').hide();
      $('#Master').show();
      this.fillInCells(this.dateBeg, this.dateEnd, this.roomId, 'Mine', 'Free');
      ref = [null, null], this.dateBeg = ref[0], this.dateEnd = ref[1];
    };

    Master.prototype.onSeasonBtn = function() {
      $('#Master').hide();
      $('#Dailys').hide();
      $('#Upload').hide();
      if (Util.isEmpty($('#Season').children())) {
        $('#Season').append(this.season.html());
      }
      $('.SeasonTitle').click((function(_this) {
        return function(event) {
          return _this.season.onMonthClick(event);
        };
      })(this));
      this.season.showMonth(this.Data.month);
      $('#ResAdd').hide();
      $('#ResTbl').hide();
      $('#Season').show();
    };

    Master.prototype.onDailysBtn = function() {
      $('#ResAdd').hide();
      $('#ResTbl').hide();
      $('#Master').hide();
      $('#Season').hide();
      $('#Upload').hide();
      if (Util.isEmpty($('#Dailys').children())) {
        $('#Dailys').append(this.dailysHtml());
      }
      $('#Dailys').show();
    };

    Master.prototype.onUploadBtn = function() {
      $('#ResAdd').hide();
      $('#ResTbl').hide();
      $('#Master').hide();
      $('#Season').hide();
      $('#Dailys').hide();
      if (Util.isEmpty($('#Upload').children())) {
        $('#Upload').append(this.upload.html());
      }
      this.upload.bindUploadPaste();
      $('#UpdateRes').click(this.upload.onUpdateRes);
      $('#Upload').show();
    };

    Master.prototype.readyMaster = function() {
      $('#Master').empty();
      $('#Master').append(this.html());
      $('#ResAdd').empty();
      $('#ResAdd').append(this.input.html());
      $('#ResAdd').hide();
      $('#ResTbl').empty();
      $('#ResTbl').append(this.resvHead());
      this.showMonth(this.Data.month);
      $('.PrevMonth').click((function(_this) {
        return function(event) {
          return _this.onMonthClick(event);
        };
      })(this));
      $('.ThisMonth').click((function(_this) {
        return function(event) {
          return _this.onMonthClick(event);
        };
      })(this));
      $('.NextMonth').click((function(_this) {
        return function(event) {
          return _this.onMonthClick(event);
        };
      })(this));
      this.resvSortClick('RHBooked', 'booked');
      this.resvSortClick('RHRoom', 'roomId');
      this.resvSortClick('RHArrive', 'arrive');
      this.resvSortClick('RHStayTo', 'stayto');
      this.resvSortClick('RHName', 'last');
      this.resvSortClick('RHStatus', 'status');
      this.res.selectAllResvs(this.readyCells);
      this.input.action();
    };

    Master.prototype.resvSortClick = function(id, prop) {
      return $('#' + id).click((function(_this) {
        return function() {
          return _this.resvBody(_this.res.resvArrayByProp(_this.dateBeg, _this.dateEnd, prop));
        };
      })(this));
    };


    /*
    resId   = $cell.attr('data-res'    )
    resv    = @res.getResv( date, @roomId )
    title   = if resv? then resv.last + ' $' + resv.total else 'Free'
    $cell.attr('title', title ) # if title isnt 'Free'
     */

    Master.prototype.readyCells = function() {
      var doCell;
      this.resvBody(this.res.resvArrayByDate(this.Data.today()));
      doCell = (function(_this) {
        return function(event) {
          var $cell, date, ref, ref1, ref2, status;
          $cell = $(event.target);
          status = $cell.attr('data-status');
          date = $cell.attr('data-date');
          _this.roomId = $cell.attr('data-roomId');
          _this.fillInCells(_this.fillBeg, _this.fillEnd, _this.fillRoomId, 'Mine', 'Free');
          if (_this.resMode === 'Table') {
            ref = _this.mouseDatesTable(date, event), _this.dateBeg = ref[0], _this.dateEnd = ref[1];
            _this.doResv(_this.dateBeg, _this.dateEnd, 'arrive');
          } else if (_this.resMode === 'Input') {
            ref1 = _this.mouseDatesTable(date, event), _this.dateBeg = ref1[0], _this.dateEnd = ref1[1];
            if (_this.fillInCells(_this.dateBeg, _this.dateEnd, _this.roomId, 'Free', 'Mine')) {
              _this.input.createResv(_this.dateBeg, _this.dateEnd, _this.roomId);
              ref2 = [_this.dateBeg, _this.dateEnd, _this.roomId], _this.fillBeg = ref2[0], _this.fillEnd = ref2[1], _this.fillRoomId = ref2[2];
            } else {
              _this.doResvUpdate(date, _this.roomId);
            }
          }
        };
      })(this);
      $('[data-cell="y"]').click(doCell);
      $('[data-cell="y"]').contextmenu(doCell);
    };

    Master.prototype.doResvUpdate = function(date, roomId) {
      var resv;
      resv = this.res.getResv(date, roomId);
      if (resv != null) {
        resv.action = 'put';
        this.input.populateResv(resv);
      }
    };

    Master.prototype.doResv = function(beg, end, prop) {
      var resvs;
      resvs = {};
      if (end != null) {
        resvs = this.res.resvArrayByProp(beg, end, prop);
      } else {
        resvs = this.res.resvArrayByDate(beg);
      }
      return this.resvBody(resvs);
    };

    Master.prototype.mouseDatesTable = function(date, event) {
      if (event.buttons === 2) {
        this.dateEnd = date;
      } else {
        this.dateBeg = date;
      }
      return [this.dateBeg, this.dateEnd];
    };

    Master.prototype.mouseDatesInput = function(date) {
      if ((this.dateBeg != null) && this.dateBeg <= date) {
        this.dateEnd = date;
      } else {
        this.dateBeg = date;
        this.dateEnd = date;
      }
      return [this.dateBeg, this.dateEnd];
    };

    Master.prototype.fillInCells = function(begDate, endDate, roomId, freeStatus, fillStatus) {
      var $cell, $cells, cstat, i, len, nxtDate;
      if (!((begDate != null) && (endDate != null) && (roomId != null))) {
        return;
      }
      $cells = [];
      nxtDate = begDate;
      while (nxtDate <= endDate) {
        $cell = this.$cell('M', nxtDate, roomId);
        cstat = $cell.attr('data-status');
        if (cstat === freeStatus || cstat === fillStatus || cstat === 'Cancel') {
          $cells.push($cell);
          nxtDate = this.Data.advanceDate(nxtDate, 1);
        } else {
          return false;
        }
      }
      for (i = 0, len = $cells.length; i < len; i++) {
        $cell = $cells[i];
        this.$cellStatus($cell, fillStatus);
      }
      return true;
    };

    Master.prototype.$cellStatus = function($cell, status) {
      return $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    Master.prototype.listenToDays = function() {
      var doDays;
      doDays = (function(_this) {
        return function(dayId, day) {
          if ((dayId != null) && (day != null)) {
            _this.res.days[dayId] = day;
            return _this.onAlloc(dayId, day);
          }
        };
      })(this);
      this.res.onDay('add', doDays);
      this.res.onDay('put', doDays);
    };

    Master.prototype.listenToResv = function() {
      var doAdd;
      doAdd = (function(_this) {
        return function(resId, resv) {
          if ((resId != null) && (resv != null) && !_this.res.resvs[resId]) {
            return _this.res.resvs[resId] = resv;
          }
        };
      })(this);
      this.res.onRes('add', doAdd);
      this.res.onRes('put', doAdd);
    };

    Master.prototype.selectToDays = function() {
      var doDays;
      doDays = (function(_this) {
        return function(days) {
          return _this.allocDays(days);
        };
      })(this);
      this.res.onDays('select', doDays);
      this.store.select('Days');
    };

    Master.prototype.allocDays = function(days) {
      var day, dayId;
      for (dayId in days) {
        if (!hasProp.call(days, dayId)) continue;
        day = days[dayId];
        this.onAlloc(dayId, day);
      }
    };

    Master.prototype.onAlloc = function(dayId, day) {
      var date, roomId;
      date = this.Data.toDate(dayId);
      roomId = this.Data.roomId(dayId);
      this.allocCell(roomId, date, day.status);
      this.season.allocCell(roomId, date, day.status);
    };

    Master.prototype.cellId = function(pre, date, roomId) {
      return pre + date + roomId;
    };

    Master.prototype.$cell = function(pre, date, roomId) {
      return $('#' + this.cellId(pre, date, roomId));
    };

    Master.prototype.createCell = function(roomId, date) {
      var day, resId, status;
      day = this.res.day(date, roomId);
      status = day.status;
      resId = day.resId;
      return "<td id=\"" + (this.cellId('M', date, roomId)) + "\" class=\"room-" + status + "\" data-status=\"" + status + "\" data-res=\"" + resId + "\" data-roomId=\"" + roomId + "\" data-date=\"" + date + "\" data-cell=\"y\"></td>";
    };

    Master.prototype.allocCell = function(roomId, date, status) {
      this.cellStatus(this.$cell('M', date, roomId), status);
    };

    Master.prototype.cellStatus = function($cell, status) {
      $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    Master.prototype.onMonthClick = function(event) {
      this.showMonth($(event.target).text());
    };

    Master.prototype.showMonth = function(month) {
      var $master;
      $master = $('#Master');
      if (month === this.showingMonth) {
        this.removeAllMonthStyles();
        $master.css({
          height: '700px'
        });
        $master.children().show();
        this.showingMonth = 'Master';
      } else {
        $master.children().hide();
        $master.css({
          height: '300px'
        });
        $('#' + month).css({
          left: 0,
          top: 0,
          width: '100%',
          height: '290px',
          fontSize: '14px'
        }).show();
        this.showingMonth = month;
      }
    };

    Master.prototype.removeAllMonthStyles = function() {
      var i, len, month, ref, results;
      ref = this.Data.season;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        month = ref[i];
        results.push($('#' + month).removeAttr('style'));
      }
      return results;
    };

    Master.prototype.html = function() {
      var htm, i, len, month, ref;
      htm = "";
      ref = this.Data.season;
      for (i = 0, len = ref.length; i < len; i++) {
        month = ref[i];
        htm += "<div id=\"" + month + "\" class=\"" + month + "\">" + (this.roomsHtml(this.Data.year, month)) + "</div>";
      }
      return htm;
    };

    Master.prototype.resvHead = function() {
      var htm;
      htm = "<table class=\"RTTable\"><thead><tr>";
      htm += "<th id=\"RHArrive\">Arrive</th><th id=\"RHStayTo\">Stay To</th><th id=\"RHNights\">Nights</th><th id=\"RHRoom\"  >Room</th>";
      htm += "<th id=\"RHName\"  >Name</th>  <th id=\"RHGuests\">Guests</th> <th id=\"RHStatus\">Status</th><th id=\"RHBooked\">Booked</th>";
      htm += "<th id=\"RHPrice\" >Price</th> <th id=\"RHPrice\" >Total</th>  <th id=\"RHTax\"   >Tax</th>   <th id=\"RHCharge\">Charge</th>";
      htm += "</tr></thead><tbody id=\"RTBody\"></tbody></table>";
      return htm;
    };

    Master.prototype.resvBody = function(resvs) {
      var arrive, booked, charge, htm, i, len, r, stayto, tax;
      $('#RTBody').empty();
      htm = "";
      for (i = 0, len = resvs.length; i < len; i++) {
        r = resvs[i];
        arrive = this.Data.toMMDD(r.arrive);
        stayto = this.Data.toMMDD(r.stayto);
        booked = this.Data.toMMDD(r.booked);
        tax = Util.toFixed(r.total * this.Data.tax);
        charge = Util.toFixed(r.total + parseFloat(tax));
        htm += "<tr>";
        htm += "<td class=\"RTArrive\">" + arrive + "  </td><td class=\"RTStayto\">" + stayto + "</td><td class=\"RTNights\">" + r.nights + "</td>";
        htm += "<td class=\"RTRoomId\">" + r.roomId + "</td><td class=\"RTLast\"  >" + r.last + "</td><td class=\"RTGuests\">" + r.guests + "</td>";
        htm += "<td class=\"RTStatus\">" + r.status + "</td><td class=\"RTBooked\">" + booked + "</td><td class=\"RTPrice\" >$" + r.price + "</td>";
        htm += "<td class=\"RTTotal\" >$" + r.total + "</td><td class=\"RTTax\"   >$" + tax + "  </td><td class=\"RTCharge\">$" + charge + " </td></tr>";
      }
      return $('#RTBody').append(htm);
    };

    Master.prototype.roomsHtml = function(year, month) {
      var begDay, date, day, endDay, htm, i, j, k, monthIdx, nextMonth, prevMonth, ref, ref1, ref2, ref3, ref4, ref5, ref6, room, roomId, weekday, weekdayIdx;
      monthIdx = this.Data.months.indexOf(month);
      prevMonth = monthIdx > 4 ? "<span class=\"PrevMonth\">" + this.Data.months[monthIdx - 1] + "</span>" : "";
      nextMonth = monthIdx < 9 ? "<span class=\"NextMonth\">" + this.Data.months[monthIdx + 1] + "</span>" : "";
      begDay = 1;
      endDay = this.Data.numDayMonth[monthIdx];
      weekdayIdx = new Date(2000 + year, monthIdx, 1).getDay();
      htm = "<div class=\"MasterTitle\">" + prevMonth + "<span class=\"ThisMonth\">" + month + "</span>" + nextMonth + "</div>";
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
          htm += this.createCell(roomId, date);
        }
        htm += "</tr>";
      }
      htm += "</tbody></table>";
      return htm;
    };

    Master.prototype.dailysHtml = function() {
      var htm;
      htm = "";
      htm += "<h1 class=\"DailysH1\">Daily Activities</h1>";
      htm += "<h2 class=\"DailysH2\">Arrivals</h2>";
      htm += "<h2 class=\"DailysH2\">Departures</h2>";
      return htm;
    };

    return Master;

  })();

}).call(this);
