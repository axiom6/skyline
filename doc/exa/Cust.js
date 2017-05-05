// Generated by CoffeeScript 1.12.2
(function() {
  var Cust;

  Cust = (function() {
    module.exports = Cust;

    Cust.Data = require('data/Cust.json');

    function Cust(stream, store, Data) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
    }

    Cust.prototype.createCust = function(first, last, phone, email, source) {
      var cust;
      cust = {};
      cust.key = this.Data.genCustKey(phone);
      cust.first = first;
      cust.last = last;
      cust.phone = phone;
      cust.email = email;
      cust.source = source;
      this.add(cust.key, cust);
      return cust;
    };

    Cust.prototype.add = function(id, cust) {
      return this.store.add('Cust', id, cust);
    };

    Cust.prototype.get = function(id) {
      return this.store.get('Cust', id);
    };

    Cust.prototype.put = function(id, cust) {
      return this.store.put('Cust', id, cust);
    };

    Cust.prototype.del = function(id) {
      return this.store.del('Cust', id);
    };

    return Cust;

  })();

}).call(this);