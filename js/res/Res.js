// Generated by CoffeeScript 1.12.2
(function() {
  var Res;

  Res = (function() {
    function Res() {}

    module.exports = Res;

    Res.init = function() {
      return Util.ready(function() {
        var Book, Cust, Room, Store, book, cust, room;
        Room = require('js/res/Room');
        Cust = require('js/res/Cust');
        Book = require('js/res/Book');
        Store = require('js/store/Store');
        room = new Room();
        cust = new Cust();
        book = new Book(room, cust);
        return book.ready();
      });
    };

    return Res;

  })();

  Res.init();

}).call(this);
