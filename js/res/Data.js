// Generated by CoffeeScript 1.12.2
(function() {
  var Data,
    hasProp = {}.hasOwnProperty;

  Data = (function() {
    function Data() {}

    module.exports = Data;

    Data.legacy = ["unkn", "canc", "free", "mine", "prep", "depo", "chan", "book", "cnew", "bnew"];

    Data.statuses = ["Unknown", "Cancel", "Free", "Mine", "Prepaid", "Deposit", "Booking", "Skyline", "BookNew", "SkylNew"];

    Data.colors = ["#E8E8E8", "#EEEEEE", "#D3D3D3", "#BBBBBB", "#AAAAAA", "#AAAAAA", "#888888", "#777777", "#444444", "#333333"];

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

    Data.month = Data.months[Data.monthIdx];

    Data.newDays = 3;

    Data.numDays = 15;

    Data.begMay = 15;

    Data.begDay = Data.month === 'May' ? Data.begMay : 1;

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

    Data.advanceDate = function(date, numDays) {
      var dd, mi, ref, yy;
      if (!Data.isDate(date)) {
        Util.trace('advanceDate', date);
      }
      ref = this.yymidd(date), yy = ref[0], mi = ref[1], dd = ref[2];
      dd += numDays;
      if (dd > Data.numDayMonth[mi]) {
        dd = dd - Data.numDayMonth[mi];
        mi++;
      }
      return Data.toDateStr(dd, mi, yy);
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

    Data.bookingResvs = "Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nAmber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833\nLynda Krupa 3 guests	31 July 2017	04 August 2017	Upper Skyline South	30 June 2017	OK	US$620	US$93	1652225524\nSara Zink 4 guests	04 August 2017	07 August 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1054573838\nRyan Mitchell 4 guests	18 August 2017	20 August 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1192666554\nGeorge Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856\nMichael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744";

    Data.weird = "Elisabetta Casali 16 guests	09 August 2017	11 August 2017	#4 One Room Cabin, #6 Large River Cabin	30 June 2017	OK	US$890	US$133.50	1563316762\nElisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958";

    Data.bookingResvsB = "Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nAmber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833\nLynda Krupa 3 guests	31 July 2017	04 August 2017	Upper Skyline South	30 June 2017	OK	US$620	US$93	1652225524\nSara Zink 4 guests	04 August 2017	07 August 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1054573838\nElisabetta Casali 16 guests	09 August 2017	11 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	OK	US$890	US$133.50	1563316762\nElisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958\nRyan Mitchell 4 guests	18 August 2017	20 August 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1192666554\nGeorge Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856\nMichael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744\nMary Hagen 2 guests	04 August 2017	06 August 2017	#4 One Room Cabin	29 June 2017	OK	US$290	US$43.50	1340661006\nSteven Ravel 4 guests	28 July 2017	30 July 2017	Upper Skyline South	28 June 2017	OK	US$310	US$46.50	1217657012\nDonna Bardallis 3 guests	28 July 2017	30 July 2017	#8 Western Unit	26 June 2017	OK	US$240	US$36	1368306301\nStephanie Hedgecock 8 guests	04 August 2017	06 August 2017	#3 Southwest Spa	24 June 2017	OK	US$630	US$94.50	1772131650\nMelissa Seacreas 3 guests 1 guest message to answer	01 September 2017	04 September 2017	#8 Western Unit	24 June 2017	OK	US$360	US$54	1555046433\nLAYLA YEAGER 12 guests 2 guest messages to answer	01 August 2017	03 August 2017	#6 Large River Cabin	22 June 2017	OK	US$630	US$94.50	1270507767\nLaura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864\nKaren Palmer 4 guests	18 August 2017	21 August 2017	#8 Western Unit	16 June 2017	OK	US$360	US$54	1747537592\nMargaret Dreiling 1 guest	08 September 2017	10 September 2017	Upper Skyline South	15 June 2017	OK	US$310	US$46.50	1977820063\nSarah Troia 12 guests	04 August 2017	06 August 2017	#6 Large River Cabin	14 June 2017	OK	US$630	US$94.50	1175185436\nMohamed Basiouny 4 guests	19 August 2017	21 August 2017	Upper Skyline South	13 June 2017	OK	US$310	US$46.50	2008176523\nkarissa Wight 4 guests	07 September 2017	09 September 2017	#4 One Room Cabin	13 June 2017	OK	US$290	US$43.50	1779163724\nInez Cunningham 3 guests	07 September 2017	13 September 2017	#3 Southwest Spa	13 June 2017	OK	US$1890	US$283.50	1831513503\nSHIU TAK LEUNG 2 guests	14 August 2017	17 August 2017	Upper Skyline South	12 June 2017	OK	US$465	US$69.75	1679266889\nTony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143\nterrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222\nDebbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879\nARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823\nTerri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150\nCarol Leech 4 guests	14 August 2017	16 August 2017	#8 Western Unit	07 June 2017	OK	US$260	US$39	1740250954\nVirginia Clark 4 guests 1 guest message to answer	10 August 2017	13 August 2017	#8 Western Unit	06 June 2017	OK	US$390	US$58.50	1853252311\nTodd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592";

    Data.Canceled = "Pauline McClendon 5 guests	25 August 2017	27 August 2017	#6 Large River Cabin	29 June 2017	Canceled	US$0	US$0	1335821435\nErma Henry 1 guest	31 July 2017	30 August 2017	#4 One Room Cabin	25 June 2017	Canceled	US$0	US$0	1225084642\nMelissa Seacreas 3 guests	01 September 2017	04 September 2017	#8 Western Unit	23 June 2017	Canceled	US$0	US$0	1822387695\nStephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1120884797\nvinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0	US$0	1438534254\nsusannah mitchell 1 guest	31 August 2017	03 September 2017	#1 One Room Cabin	04 June 2017	Canceled	US$0	US$0	1034276945\nGregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0	US$0	1357716307\nJohnathan Koeltzow 2 guests	11 August 2017	13 August 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1756807815\nclarice fenton 4 guests	22 July 2017	26 July 2017	Upper Skyline South	23 June 2017	Canceled	US$0	US$0	1538156772\nSusan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	Canceled	US$0	US$0	2079181490\nChangying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829\nT Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653\nHan Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728\nRitu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274\nRyan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834\nLance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506\nDesiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266\nJeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878\nKarthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	Canceled	US$0	US$0	1919159565";

    Data.bookingResvsA = "Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nGregory Hebbler 2 guests	18 July 2017	25 July 2017	#5 Cabin with a View	28 June 2017	OK	US$1365	US$204.75	1643093209\nShivrajsinh Rana 3 guests	30 June 2017	03 July 2017	#8 Western Unit	28 June 2017	OK	US$360	US$54	1643057108\nThelma Carrera 3 guests	27 June 2017	29 June 2017	Upper Skyline South	27 June 2017	OK	US$310	US$46.50	1799824520\nJessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577";

    return Data;

  })();

}).call(this);
