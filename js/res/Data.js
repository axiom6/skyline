// Generated by CoffeeScript 1.12.2
(function() {
  var Data,
    hasProp = {}.hasOwnProperty;

  Data = (function() {
    function Data() {}

    module.exports = Data;

    Data.legacy = ["unkn", "canc", "free", "mine", "prep", "depo", "chan", "book", "cnew", "bnew"];

    Data.statuses = ["Unknown", "Cancel", "Free", "Mine", "Prepaid", "Deposit", "Booking", "Skyline", "BookNew", "SkylNew"];

    Data.colors = ["#E8E8E8", "#EEEEEE", "#FFFFFF", "#BBBBBB", "#AAAAAA", "#AAAAAA", "#888888", "#444444", "#333333", "#222222"];

    Data.colors1 = ["yellow", "whitesmoke", "lightgrey", "green", "#555555", "#000000", "blue", "slategray", "purple", "black"];

    Data.statusesSel = ["Deposit", "Skyline", "Prepaid", "Booking", "Cancel"];

    Data.sources = ["Skyline", "Booking", "Website"];

    Data.tax = 0.1055;

    Data.season = ["May", "June", "July", "August", "September", "October"];

    Data.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    Data.months3 = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    Data.numDayMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    Data.weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    Data.days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"];

    Data.persons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];

    Data.nighti = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"];

    Data.pets = ["0", "1", "2", "3", "4"];

    Data.petPrice = 12;

    Data.year = 17;

    Data.spaOptOut = 20;

    Data.monthIdx = new Date().getMonth();

    Data.monthIdx = 4 <= Data.monthIdx && Data.monthIdx <= 9 ? Data.monthIdx : 4;

    Data.newDays = 3;

    Data.numDays = 15;

    Data.begMay = 15;

    Data.begDay = Data.monthIdx === 4 ? Data.begMay : 1;

    Data.beg = '170515';

    Data.end = '171009';

    Data.configSkytest = {
      apiKey: "AIzaSyAH4gtA-AVzTkwO_FXiEOlgDRK1rKLdJ2k",
      authDomain: "skytest-25d1c.firebaseapp.com",
      databaseURL: "https://skytest-25d1c.firebaseio.com",
      storageBucket: "skytest-25d1c.appspot.com",
      messagingSenderId: "978863515797"
    };

    Data.configSkyline = {
      apiKey: "AIzaSyBjMGVzZ6JgZBs8O7mBQfH6clHYDmjTsGU",
      authDomain: "skyline-fed2b.firebaseapp.com",
      databaseURL: "https://skyline-fed2b.firebaseio.com",
      storageBucket: "skyline-fed2b.appspot.com/",
      messagingSenderId: "279547846849"
    };

    Data.toStatus = function(status) {
      var index;
      index = Data.legacy.indexOf(status);
      if (index > 0) {
        return Data.statuses[index];
      } else {
        return status;
      }
    };

    Data.toColor = function(status) {
      var index;
      index = Data.statuses.indexOf(status);
      if (index > 0) {
        return Data.colors[index];
      } else {
        return "yellow";
      }
    };

    Data.config = function(uri) {
      if (uri === 'skyline') {
        return this.configSkyline;
      } else {
        return this.configSkytest;
      }
    };

    Data.databases = {
      skyline: "skyline-fed2b",
      skytest: "skytest-25d1c"
    };

    Data.stripeTestKey = "sk_test_FCa6Z3AusbsdhyV93B4CdWnV";

    Data.stripeTestPub = "pk_test_0VHIhWRH8hFwSeP2n084Ze4L";

    Data.stripeLiveKey = "sk_live_CCbj5oirIeHwTlyKVXJnbrgt";

    Data.stripeLivePub = "pk_live_Lb83wXgDVIuRoEpmK9ji2AU3";

    Data.stripeCurlKey = "sk_test_lUkwzunJkKfFmcEjHBtCfvhs";

    Data.resId = function(date, roomId) {
      return date + roomId;
    };

    Data.dayId = function(date, roomId) {
      return date + roomId;
    };

    Data.roomId = function(anyId) {
      return anyId.substr(6, 1);
    };

    Data.getRoomIdFromNum = function(num) {
      var roomId;
      roomId = num;
      if (roomId === 9) {
        roomId = 'N';
      }
      if (roomId === 10) {
        roomId = 'S';
      }
      return roomId;
    };

    Data.toDate = function(anyId) {
      if (anyId != null) {
        return anyId.substr(0, 6);
      } else {
        return Util;
      }
    };

    Data.genResId = function(roomUIs) {
      var days, resId, roomId, roomUI;
      resId = "";
      for (roomId in roomUIs) {
        if (!hasProp.call(roomUIs, roomId)) continue;
        roomUI = roomUIs[roomId];
        if (!(!Util.isObjEmpty(roomUI.days))) {
          continue;
        }
        days = Util.keys(roomUI.days).sort();
        resId = days[0] + roomId;
        break;
      }
      if (!Util.isStr(resId)) {
        Util.error('Data.getResId() resId blank');
      }
      return resId;
    };

    Data.genCustId = function(phone) {
      return Util.padEnd(phone.substr(0, 10), 10, '_');
    };

    Data.genPaymentId = function(resId, payments) {
      var paySeq, pays;
      pays = Util.keys(payments).sort();
      paySeq = pays.length > 0 ? toString(parseInt(pays[pays.length - 1]) + 1) : '1';
      return resId + paySeq;
    };

    Data.randomCustKey = function() {
      return Math.floor(Math.random() * (9999999999 - 1000000000)) + 1000000000;
    };

    Data.today = function() {
      var date, year;
      date = new Date();
      year = date.getFullYear() - 2000;
      return Data.toDateStr(date.getDate(), date.getMonth(), year);
    };

    Data.month = function() {
      return Data.months[Data.monthIdx];
    };

    Data.numDaysMonth = function(month) {
      var mi;
      if (month == null) {
        month = Data.month();
      }
      mi = Data.months.indexOf(month);
      return Data.numDayMonth[mi];
    };

    Data.advanceDate = function(date, numDays) {
      var dd, mi, ref, yy;
      ref = this.yymidd(date), yy = ref[0], mi = ref[1], dd = ref[2];
      dd += numDays;
      if (dd > Data.numDayMonth[mi]) {
        dd = dd - Data.numDayMonth[mi];
        mi++;
      } else if (dd < 1) {
        mi--;
        dd = Data.numDayMonth[mi];
      }
      return Data.toDateStr(dd, mi, yy);
    };

    Data.advanceMMDD = function(mmdd, numDays) {
      var dd, mi, ref;
      ref = this.midd(mmdd), mi = ref[0], dd = ref[1];
      dd += numDays;
      if (dd > Data.numDayMonth[mi]) {
        dd = dd - Data.numDayMonth[mi];
        mi++;
      } else if (dd < 1) {
        mi--;
        dd = Data.numDayMonth[mi];
      }
      return Util.pad(mi + 1) + '/' + Util.pad(dd);
    };

    Data.nights = function(arrive, depart) {
      var arriveDay, arriveMon, departDay, departMon, num;
      num = 0;
      arriveDay = parseInt(arrive.substr(4, 2));
      arriveMon = parseInt(arrive.substr(2, 2));
      departDay = parseInt(depart.substr(4, 2));
      departMon = parseInt(depart.substr(2, 2));
      if (arriveMon === departMon) {
        num = departDay - arriveDay;
      } else if (arriveMon + 1 === departMon) {
        num = Data.numDayMonth[arriveMon - 1] - arriveDay + departDay;
      }
      return Math.abs(num);
    };

    Data.weekday = function(date) {
      var dd, mi, ref, weekdayIdx, yy;
      ref = this.yymidd(date), yy = ref[0], mi = ref[1], dd = ref[2];
      weekdayIdx = new Date(2000 + yy, mi, dd).getDay();
      return Data.weekdays[weekdayIdx];
    };

    Data.isDate = function(date) {
      var dd, mi, ref, valid, yy;
      ref = this.yymidd(date), yy = ref[0], mi = ref[1], dd = ref[2];
      valid = true;
      valid &= yy === Data.year;
      valid &= 0 <= mi && mi <= 11;
      valid &= 1 <= dd && dd <= 31;
      return valid;
    };

    Data.yymidd = function(date) {
      var dd, mi, yy;
      yy = parseInt(date.substr(0, 2));
      mi = parseInt(date.substr(2, 2)) - 1;
      dd = parseInt(date.substr(4, 2));
      return [yy, mi, dd];
    };

    Data.midd = function(mmdd) {
      var dd, mi;
      mi = parseInt(mmdd.substr(0, 2)) - 1;
      dd = parseInt(mmdd.substr(3, 2));
      return [mi, dd];
    };

    Data.toMMDD = function(date) {
      var dd, mi, ref, yy;
      ref = this.yymidd(date), yy = ref[0], mi = ref[1], dd = ref[2];
      return Util.pad(mi + 1) + '/' + Util.pad(dd);
    };

    Data.toMMDD2 = function(date) {
      var dd, mi, ref, str, yy;
      ref = this.yymidd(date), yy = ref[0], mi = ref[1], dd = ref[2];
      str = (mi + 1).toString() + '/' + dd.toString();
      Util.log('Data.toMMDD()', date, yy, mi, dd, str);
      return str;
    };

    Data.isElem = function($elem) {
      return !(($elem != null) && ($elem.length != null) && $elem.length === 0);
    };

    Data.dayMonth = function(day) {
      var monthDay;
      monthDay = day + Data.begDay - 1;
      if (monthDay > Data.numDayMonth[this.monthIdx]) {
        return monthDay - Data.numDayMonth[Data.monthIdx];
      } else {
        return monthDay;
      }
    };

    Data.toDateStr = function(dd, mi, yy) {
      if (mi == null) {
        mi = Data.monthIdx;
      }
      if (yy == null) {
        yy = Data.year;
      }
      return yy.toString() + Util.pad(mi + 1) + Util.pad(dd);
    };

    Data.toMonth3DayYear = function(date) {
      var dd, mi, ref, yy;
      ref = Data.isDate(date) ? this.yymidd(date) : this.yymidd(Data.today()), yy = ref[0], mi = ref[1], dd = ref[2];
      Util.log('Data.yymidd()', date, yy, mi, dd);
      return Data.months3[mi] + dd.toString() + ', ' + (2000 + yy).toString();
    };

    return Data;

  })();

}).call(this);
