// Generated by CoffeeScript 1.12.2
(function() {
  var Data;

  Data = (function() {
    function Data() {}

    module.exports = Data;

    Data.testing = true;

    Data.season = ["May", "June", "July", "August", "September", "October"];

    Data.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    Data.numDayMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    Data.weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    Data.days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"];

    Data.persons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];

    Data.pets = ["0", "1", "2", "3", "4"];

    Data.petPrice = 12;

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

    Data.databases = {
      skyline: "skyline-fed2b",
      skytest: "skytest-25d1c"
    };

    Data.stripeTestKey = "sk_test_FCa6Z3AusbsdhyV93B4CdWnV";

    Data.stripeTestPub = "pk_test_0VHIhWRH8hFwSeP2n084Ze4L";

    Data.stripeLiveKey = "sk_live_CCbj5oirIeHwTlyKVXJnbrgt";

    Data.stripeLivePub = "pk_live_Lb83wXgDVIuRoEpmK9ji2AU3";

    Data.stripeCurlKey = "sk_test_lUkwzunJkKfFmcEjHBtCfvhs";

    Data.genCustKey = function(phone) {
      var custKey;
      custKey = Util.padEnd(phone.substr(0, 10), 10, '_');
      if (Data.testing) {
        return Data.randomCustKey();
      } else {
        return custKey;
      }
    };

    Data.randomCustKey = function() {
      return Math.floor(Math.random() * (9999999999 - 1000000000)) + 1000000000;
    };

    Data.genResKey = function(roomId, date) {
      return roomId + date;
    };

    Data.genPaymentKey = function(date, hour, min) {
      return date + hour + min;
    };

    Data.today = function() {
      var date, day, month, year;
      date = new Date();
      year = date.getFullYear().toString();
      month = Util.padStr(date.getMonth() + 1);
      day = Util.padStr(date.getDate());
      Util.log('Data.today', year, month, day, year + month + day);
      return year + month + day;
    };

    Data.advanceDate = function(resDate, numDays) {
      var day, dayInt, month, monthIdx, year;
      year = resDate.substr(0, 4);
      monthIdx = parseInt(resDate.substr(4, 2)) - 1;
      dayInt = parseInt(resDate.substr(6, 2)) + numDays;
      if (dayInt > this.numDayMonth[monthIdx]) {
        dayInt = dayInt - this.numDayMonth[monthIdx];
        monthIdx++;
      }
      day = Util.padStr(dayInt);
      month = Util.padStr(monthIdx + 1);
      return year + month + day;
    };

    Data.weekday = function(date) {
      var dayInt, monthIdx, weekdayIdx, year;
      year = parseInt(date.substr(0, 4));
      monthIdx = parseInt(date.substr(4, 2)) - 1;
      dayInt = parseInt(date.substr(6, 2));
      weekdayIdx = new Date(year, monthIdx, dayInt).getDay();
      return Data.weekdays[weekdayIdx];
    };

    Data.isElem = function($elem) {
      return !(($elem != null) && ($elem.length != null) && $elem.length === 0);
    };

    return Data;

  })();

}).call(this);
