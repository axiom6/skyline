// Generated by CoffeeScript 1.12.2
(function() {
  var $, Master,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Master = (function() {
    module.exports = Master;

    function Master(stream, store, Data, res) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.onSeasonClick = bind(this.onSeasonClick, this);
      this.onMasterClick = bind(this.onMasterClick, this);
      this.onAlloc = bind(this.onAlloc, this);
      this.rooms = this.res.rooms;
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
      this.res.beg = this.res.toAnyDateStr(this.res.year, 4, 15);
      this.res.end = this.res.toAnyDateStr(this.res.year, 9, 15);
      this.res.dateRange();
    }

    Master.prototype.ready = function() {
      $('#Master').append(this.masterHtml());
      $('#Season').append(this.seasonHtml());
      $('.MasterTitle').click((function(_this) {
        return function(event) {
          return _this.onMasterClick(event);
        };
      })(this));
      $('.SeasonTitle').click((function(_this) {
        return function(event) {
          return _this.onSeasonClick(event);
        };
      })(this));
    };

    Master.prototype.onAlloc = function(roomId, days) {
      var day, dayId;
      for (dayId in days) {
        if (!hasProp.call(days, dayId)) continue;
        day = days[dayId];
        this.allocMasterCell(roomId, dayId, day.status);
        this.allocSeasonCell(roomId, dayId, day.status);
      }
    };

    Master.prototype.createMasterCell = function(roomId, room, date) {
      var status;
      status = this.res.dayBooked(room, date);
      return "<td id=\"M" + (date + roomId) + "\" class=\"room-" + status + "\" data-status=\"" + status + "\"></td>";
    };

    Master.prototype.allocMasterCell = function(roomId, day, status) {
      return this.cellMasterStatus($('#M' + day + roomId), status);
    };

    Master.prototype.allocSeasonCell = function(roomId, day, status) {
      return this.cellSeasonStatus($('#S' + day + roomId), status);
    };

    Master.prototype.cellMasterStatus = function($cell, status) {
      return $cell.removeClass().addClass("room-" + status).attr('data-status', status);
    };

    Master.prototype.cellSeasonStatus = function($cell, status) {
      return $cell.removeClass().addClass("own-" + status).attr('data-status', status);
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
        return $month.css({
          left: 0,
          top: 0,
          width: '100%',
          height: '450px'
        }).show();
      } else {
        $month.css(this.lastMaster);
        $master.children().show();
        return this.lastMaster.height = 0;
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
        return $month.css({
          left: 0,
          top: 0,
          width: '100%',
          height: '450px'
        }).show();
      } else {
        $month.css(this.lastSeason);
        $season.children().show();
        return this.lastSeason.height = 0;
      }
    };

    Master.prototype.masterHtml = function() {
      var htm, i, len, month, ref;
      htm = "";
      ref = this.Data.season;
      for (i = 0, len = ref.length; i < len; i++) {
        month = ref[i];
        htm += "<div id=\"" + month + "\" class=\"" + month + "\">" + (this.roomsHtml(this.res.year, month)) + "</div>";
      }
      return htm;
    };

    Master.prototype.roomsHtml = function(year, month) {
      var begDay, date, day, endDay, htm, i, j, k, monthIdx, ref, ref1, ref2, ref3, ref4, ref5, ref6, room, roomId, weekday, weekdayIdx;
      monthIdx = this.Data.months.indexOf(month);
      begDay = month !== 'May' ? 1 : 17;
      endDay = month !== 'October' ? this.Data.numDayMonth[monthIdx] : 15;
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
          date = this.toDateStr(monthIdx, day);
          htm += this.createMasterCell(roomId, room, date);
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
      var col, htm, i, roomId, status;
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
        status = this.res.dayBooked(this.rooms[roomId], this.toDateStr(monthIdx, day));
        if (status !== 'free') {
          htm += "<span id=\"" + (this.roomDayId(monthIdx, day, roomId)) + "\" class=\"own-" + status + "\">" + roomId + "</span>";
        }
      }
      htm += "</div>";
      return htm;
    };

    Master.prototype.roomDayId = function(monthIdx, day, roomId) {
      var dayPad, monPad;
      monPad = Util.pad(monthIdx + 1);
      dayPad = Util.pad(day);
      return 'S' + roomId + this.res.year + monPad + dayPad;
    };

    Master.prototype.monthDay = function(begDay, endDay, row, col) {
      var day;
      day = row * 7 + col - begDay;
      day = 1 <= day && day <= endDay ? day : "";
      return day;
    };

    Master.prototype.toDateStr = function(monthIdx, day) {
      return this.res.year + Util.pad(monthIdx + 1) + Util.pad(day);
    };

    return Master;

  })();

}).call(this);
