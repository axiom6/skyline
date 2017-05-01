// Generated by CoffeeScript 1.12.2
(function() {
  var Guest;

  Guest = (function() {
    function Guest() {}

    module.exports = Guest;

    Guest.init = function() {
      return Util.ready(function() {
        var Book, Cust, Data, Firestore, Home, Pay, Pict, Res, Room, Stream, Test, book, cust, home, pay, pict, res, room, store, stream, test;
        Util.jquery = require('jquery');
        Stream = require('js/store/Stream');
        Firestore = require('js/store/Firestore');
        Data = require('js/res/Data');
        Room = require('js/res/Room');
        Cust = require('js/res/Cust');
        Home = require('js/res/Home');
        Pict = require('js/res/Pict');
        Res = require('js/res/Res');
        Pay = require('js/res/Pay');
        Book = require('js/res/Book');
        Test = require('js/res/Test');
        pict = new Pict();
        stream = new Stream([]);
        store = new Firestore(stream, "skytest", Data.configSkytest);
        room = new Room(stream, store, Data);
        cust = new Cust(stream, store, Data);
        home = new Home(stream, store, room, pict);
        res = new Res(stream, store, room, Data);
        pay = new Pay(stream, store, room, cust, res, home, Data);
        book = new Book(stream, store, room, cust, res, pay, pict, Data);
        test = new Test(stream, store, room, cust, res, pay, pict, book, Data);
        home.ready(book);
        return test.doTest();
      });
    };

    return Guest;

  })();

  Guest.init();

}).call(this);
