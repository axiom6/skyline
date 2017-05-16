// Generated by CoffeeScript 1.12.2
(function() {
  var Guest;

  Guest = (function() {
    function Guest() {}

    module.exports = Guest;

    Guest.init = function() {
      return Util.ready(function() {
        var Book, Data, Fire, Home, Pay, Pict, Res, Stream, Test, book, home, pay, pict, res, store, stream, test;
        Util.jquery = require('jquery');
        Stream = require('js/store/Stream');
        Fire = require('js/store/Fire');
        Data = require('js/res/Data');
        Home = require('js/res/Home');
        Pict = require('js/res/Pict');
        Res = require('js/res/Res');
        Pay = require('js/res/Pay');
        Book = require('js/res/Book');
        Test = require('js/res/Test');
        pict = new Pict();
        stream = new Stream([]);
        store = new Fire(stream, "skytest", Data.configSkytest);
        res = new Res(stream, store, Data, 'Guest');
        home = new Home(stream, store, Data, res, pict);
        pay = new Pay(stream, store, Data, res, home);
        book = new Book(stream, store, Data, res, pay, pict);
        test = new Test(stream, store, Data, res, pay, pict, book);
        book.test = test;
        return home.ready(book);
      });
    };

    return Guest;

  })();

  Guest.init();

}).call(this);
