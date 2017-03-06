// Generated by CoffeeScript 1.12.2
(function() {
  var $, Pivot, Store, pivottable;

  $ = require('jquery');

  pivottable = require('pivottable');

  Store = require('js/store/Store');

  Pivot = (function() {
    module.exports = Pivot;

    Store.Pivot = Pivot;

    function Pivot(stream, store) {
      this.stream = stream;
      this.store = store;
    }

    Pivot.prototype.select = function(table, where, htmlId) {
      var subject;
      subject = this.store.toSubject(table, 'select');
      this.stream.subscribe(subject, (function(_this) {
        return function(objects) {
          var array;
          array = Util.toArray(objects);
          return _this.show(array, htmlId);
        };
      })(this));
      this.store.select(table, where);
    };

    Pivot.prototype.show = function(array, htmlId) {
      if (htmlId == null) {
        htmlId = "output";
      }
      $('#' + htmlId).pivotUI(array);
    };

    Pivot.prototype.showPractices = function(practices, htmlId) {
      if (htmlId == null) {
        htmlId = "output";
      }
      $('#' + htmlId).pivotUI(practices, {
        sorters: function(attr) {
          switch (attr) {
            case 'plane':
              return Pivot.$.pivotUtilities.sortAs(["Information", "DataScience", "Knowledge", "Wisdow"]);
            case 'row':
              return Pivot.$.pivotUtilities.sortAs(["Learn", "Do", "Share"]);
            case 'column':
              return Pivot.$.pivotUtilities.sortAs(["Embrace", "Innovate", "Encourage"]);
            default:
              return null;
          }
        }
      });
    };

    return Pivot;

  })();

}).call(this);