// Generated by CoffeeScript 1.12.2
(function() {
  var Owner;

  Owner = (function() {
    function Owner() {}

    module.exports = Owner;

    Owner.init = function() {
      return Util.ready(function() {
        var Book, Cust, Data, Firestore, Master, Room, Stream, book, cust, master, room, store, stream;
        Stream = require('js/store/Stream');
        Firestore = require('js/store/Firestore');
        Data = require('js/res/Data');
        Room = require('js/res/Room');
        Cust = require('js/res/Cust');
        Book = require('js/res/Book');
        Master = require('js/res/Master');
        stream = new Stream([]);
        store = new Firestore(stream, "skytest", Data.configSkytest);
        room = new Room(stream, store);
        cust = new Cust(stream, store);
        book = new Book(stream, store, room, cust);
        master = new Master(stream, store, room, cust, book);
        return master.ready();
      });
    };

    return Owner;

  })();

  Owner.init();

}).call(this);
