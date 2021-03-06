// Generated by CoffeeScript 1.12.2
(function() {
  var $, Data, UI;

  $ = require('jquery');

  Data = require('js/res/Data');

  UI = (function() {
    function UI() {}

    module.exports = UI;

    UI.isEmpty = function($elem) {
      return ($elem != null) && ($elem.length != null) && $elem.length === 0;
    };

    UI.isElem = function($elem) {
      return !UI.isEmpty($elem);
    };

    UI.htmlSelect = function(htmlId, array, choice, klass, max) {
      var elem, htm, i, len, selected, style, where;
      if (klass == null) {
        klass = "";
      }
      if (max == null) {
        max = void 0;
      }
      style = Util.isStr(klass) ? klass : htmlId;
      htm = "<select name=\"" + htmlId + "\" id=\"" + htmlId + "\" class=\"" + style + "\">";
      where = max != null ? function(elem) {
        return elem <= max;
      } : function() {
        return true;
      };
      for (i = 0, len = array.length; i < len; i++) {
        elem = array[i];
        if (!(where(elem))) {
          continue;
        }
        selected = elem === Util.toStr(choice) ? "selected" : "";
        htm += "<option" + (' ' + selected) + ">" + elem + "</option>";
      }
      return htm += "</select>";
    };

    UI.htmlInput = function(htmlId, value, klass, label, type) {
      var htm, style;
      if (value == null) {
        value = "";
      }
      if (klass == null) {
        klass = "";
      }
      if (label == null) {
        label = "";
      }
      if (type == null) {
        type = "text";
      }
      style = Util.isStr(klass) ? klass : htmlId;
      htm = "";
      if (Util.isStr(label)) {
        htm += "<label for=\"" + htmlId + "\" class=\"" + (style + 'Label') + "\">" + label + "</label>";
      }
      htm += "<input id= \"" + htmlId + "\" class=\"" + style + "\" value=\"" + value + "\" type=\"" + type + "\">";
      return htm;
    };

    UI.htmlButton = function(htmlId, klass, title) {
      return "<button id=\"" + htmlId + "\" class=\"btn btn-primary " + klass + "\">" + title + "</button>";
    };

    UI.htmlArrows = function(htmlId, klass) {
      return "<span id=\"" + htmlId + "L\">&#9664;</span>\n<span id=\"" + htmlId + "\" class=\"" + klass + "\"></span>\n<span id=\"" + htmlId + "R\">&#9654;</span>";
    };

    UI.onArrowsMMDD = function(htmlId, onMMDD) {
      var decMMDD, incMMDD;
      if (onMMDD == null) {
        onMMDD = null;
      }
      decMMDD = function() {
        var $mmdd, mmdd0, mmdd1;
        $mmdd = $('#' + htmlId);
        mmdd0 = $mmdd.text();
        mmdd1 = Data.advanceMMDD(mmdd0, -1);
        $mmdd.text(mmdd1);
        if (onMMDD != null) {
          onMMDD(htmlId, mmdd0, mmdd1);
        }
      };
      incMMDD = function() {
        var $mmdd, mmdd0, mmdd1;
        $mmdd = $('#' + htmlId);
        mmdd0 = $mmdd.text();
        mmdd1 = Data.advanceMMDD(mmdd0, 1);
        $mmdd.text(mmdd1);
        if (onMMDD != null) {
          onMMDD(htmlId, mmdd0, mmdd1);
        }
      };
      $('#' + htmlId + 'L').click(decMMDD);
      $('#' + htmlId + 'R').click(incMMDD);
    };

    UI.makeSelect = function(htmlId, obj) {
      var onSelect;
      onSelect = function(event) {
        obj[htmlId] = event.target.value;
        return Util.log(htmlId, obj[htmlId]);
      };
      $('#' + htmlId).change(onSelect);
    };

    UI.makeInput = function(htmlId, obj) {
      var onInput;
      onInput = function(event) {
        obj[htmlId] = event.target.value;
        return Util.log(htmlId, obj[htmlId]);
      };
      $('#' + htmlId).change(onInput);
    };

    UI.attr = function($elem, name) {
      var value;
      value = $elem.attr(name.toLowerCase());
      Util.log('Res.attr one', name, value);
      value = Util.isStr(value) && value.charAt(0) === ' ' ? value.substr(1) : value;
      value = Util.isStr(value) ? Util.toCap(value) : value;
      Util.log('Res.attr two', name, value);
      return value;
    };

    return UI;

  })();

}).call(this);
