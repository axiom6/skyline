// Generated by CoffeeScript 1.12.2
(function() {
  var Data,
    hasProp = {}.hasOwnProperty;

  Data = (function() {
    function Data() {}

    module.exports = Data;

    Data.states = ["free", "mine", "depo", "book", "prep", "chan"];

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

    Data.monthIdx = new Date().getMonth();

    Data.monthIdx = 4 <= Data.monthIdx && Data.monthIdx <= 9 ? Data.monthIdx : 4;

    Data.month = Data.months[Data.monthIdx];

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

    Data.advanceDate = function(resDate, numDays) {
      var day, monthIdx, year;
      year = resDate.substr(0, 2);
      monthIdx = parseInt(resDate.substr(2, 2)) - 1;
      day = parseInt(resDate.substr(4, 2)) + numDays;
      if (day > Data.numDayMonth[monthIdx]) {
        day = day - Data.numDayMonth[monthIdx];
        monthIdx++;
      }
      return Data.toDateStr(day, monthIdx, year);
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
      return (mi + 1).toString() + '/' + dd.toString();
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

    Data.toDateStr = function(day, monthIdx, year) {
      if (monthIdx == null) {
        monthIdx = Data.monthIdx;
      }
      if (year == null) {
        year = Data.year;
      }
      return year.toString() + Util.pad(monthIdx + 1) + Util.pad(day);
    };

    Data.toMonth3DayYear = function(date) {
      var dd, mi, ref, yy;
      ref = Data.isDate(date) ? this.yymidd(date) : this.yymidd(Data.today()), yy = ref[0], mi = ref[1], dd = ref[2];
      Util.log('Data.yymidd()', date, yy, mi, dd);
      return Data.months3[mi] + dd.toString() + ', ' + (2000 + yy).toString();
    };

    Data.bookingResvs = "Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nJacen Roper 4 guests	23 June 2017	26 June 2017	#4 One Room Cabin	31 May 2017	OK	US$435	US$65.25	1771276433\nCherry Lofstrom 1 guest	23 June 2017	25 June 2017	#1 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065507845\nEncarnita Pascuzzi 4 guests	23 June 2017	26 June 2017	#8 Western Unit	01 June 2017	Canceled	US$0		1361910794\nJoseph Shuck 4 guests	23 June 2017	25 June 2017	Upper Skyline South	01 June 2017	OK	US$310	US$46.50	1716314897\nJana Green 4 guests	25 June 2017	27 June 2017	#2 Mountain Spa	01 June 2017	OK	US$370	US$55.50	1065504281\nAman Hota 4 guests	30 June 2017	03 July 2017	Upper Skyline South	01 June 2017	OK	US$465	US$69.75	1540200140\nlinda Nelsen 4 guests	16 June 2017	18 June 2017	#8 Western Unit	03 June 2017	OK	US$290	US$43.50	1346970369\nTanya Thomas 2 guests	23 June 2017	25 June 2017	Upper Skyline North	03 June 2017	OK	US$330	US$49.50	1584941695\nDesiree Schwalm 8 guests	16 June 2017	18 June 2017	#3 Southwest Spa	04 June 2017	Canceled	US$0		1516613627\nYessenia Chan;Che Yun Chan;So Sum Daphne Chan 8 guests	23 June 2017	25 June 2017	#3 Southwest Spa	04 June 2017	OK	US$630	US$94.50	1362060631\nKelli Pachner 4 guests	29 June 2017	07 July 2017	#2 Mountain Spa	05 June 2017	OK	US$1480	US$222	1150950465\njohn peterson 4 guests	16 June 2017	18 June 2017	Upper Skyline South	06 June 2017	OK	US$310	US$46.50	2035897444\nKristi Stoll 2 guests	22 June 2017	24 June 2017	#8 Western Unit	06 June 2017	Canceled	US$0		1120838596\nCHARLES FREEMAN 4 guests	26 June 2017	30 June 2017	#4 One Room Cabin	06 June 2017	OK	US$580	US$87	1525366564\nHari Nepal 4 guests	27 June 2017	29 June 2017	#8 Western Unit	06 June 2017	OK	US$260	US$39	1277611253\nGlenn Price 3 guests	16 June 2017	18 June 2017	Upper Skyline North	08 June 2017	OK	US$330	US$49.50	1881784832\nDaryl Schwindt 4 guests	18 June 2017	21 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1285995429\nAndrew Impagliazzo 4 guests	23 June 2017	26 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1055950974\nAnn Ross 4 guests	18 June 2017	20 June 2017	#4 One Room Cabin	10 June 2017	OK	US$290	US$43.50	1747041527\nPauline Segura 4 guests	23 June 2017	25 June 2017	#5 Cabin with a View	11 June 2017	OK	US$390	US$58.50	2086414716\nSusan Haynes 3 guests	28 June 2017	01 July 2017	#5 Cabin with a View	12 June 2017	OK	US$585	US$87.75	1315640448\nGuest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nAllison Mann 4 guests	23 July 2017	27 July 2017	#8 Western Unit	08 June 2017	OK	US$480	US$72	1529537163\nConsuelo Chavarria 4 guests 2 guest messages to answer	03 July 2017	05 July 2017	#8 Western Unit	02 June 2017	OK	US$290	US$43.50	1289646030\nDebbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879\nDebra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572\nDesiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0		1724384266\nDuelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257\nEric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525\nGregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0		1357716307\nJeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580\nJeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0		1849068878\nKarthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	OK	US$290	US$43.50	1919159565\nLance richardson 2 guests 1 guest message to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1853235506\nLinda Kroeger 12 guests	05 July 2017	09 July 2017	#6 Large River Cabin	02 June 2017	OK	US$1260	US$189	1784265520\nMichael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266\nNirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416\nOlga Diachuk 2 guests	01 July 2017	04 July 2017	Upper Skyline North	03 June 2017	OK	US$495	US$74.25	1276208822\nPatricia Curtis 4 guests	08 July 2017	11 July 2017	#4 One Room Cabin	07 June 2017	OK	US$435	US$65.25	2065156596\nRitu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0		1760649274\nRyan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0		1490387834\nScott Bonnel 1 guest	03 July 2017	08 July 2017	#7 Western Spa	09 June 2017	OK	US$875	US$131.25	1152594137\nStephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0		1120884797\nTaylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994\nTeresa Kile 4 guests	03 July 2017	07 July 2017	Upper Skyline South	06 June 2017	OK	US$620	US$93	1529786552\nTerri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150\nterrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222\nThomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793\nThomas Sturrock 12 guests	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110\nTiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563\nVanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051\nWanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	02 June 2017	Canceled	US$0		1936424490\nGuest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823\nStephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0		1120884797\nvinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0		1438534254\nGuest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number\nTodd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592\nTony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143";

    return Data;

  })();

}).call(this);
