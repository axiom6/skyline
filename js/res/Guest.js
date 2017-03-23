// Generated by CoffeeScript 1.12.2
(function() {
  var Guest;

  Guest = (function() {
    function Guest() {}

    module.exports = Guest;

    Guest.init = function() {
      return Util.ready(function() {
        var Alloc, Book, Cust, Data, Firestore, Master, Res, Room, Stream, alloc, book, cust, master, res, room, store, stream;
        Stream = require('js/store/Stream');
        Firestore = require('js/store/Firestore');
        Data = require('js/res/Data');
        Room = require('js/res/Room');
        Cust = require('js/res/Cust');
        Res = require('js/res/Res');
        Book = require('js/res/Book');
        Master = require('js/res/Master');
        Alloc = require('js/res/Alloc');
        stream = new Stream([]);
        store = new Firestore(stream, "skytest", Data.configSkytest);
        room = new Room(stream, store, Data);
        cust = new Cust(stream, store);
        res = new Res(stream, store, room, cust);
        book = new Book(stream, store, room, cust, res);
        master = new Master(stream, store, room, cust, res);
        alloc = new Alloc(stream, store, room, cust, res, master, book);
        book.ready();
        master.ready();
        return Util.noop(alloc);
      });
    };

    return Guest;

  })();

  Guest.init();

}).call(this);
