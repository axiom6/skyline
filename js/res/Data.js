// Generated by CoffeeScript 1.12.2
(function() {
  var Data;

  Data = (function() {
    module.exports = Data;

    function Data(stream, store, room, cust, book) {
      this.stream = stream;
      this.store = store;
      this.room = room;
      this.cust = cust;
      this.book = book;
    }

    Data.prototype.initAllTables = function() {};

    Data.prototype.dropAllTables = function() {};

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

    return Data;

  })();

}).call(this);
