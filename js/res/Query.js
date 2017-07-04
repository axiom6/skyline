// Generated by CoffeeScript 1.12.2
(function() {
  var $, Query;

  $ = require('jquery');

  Query = (function() {
    module.exports = Query;

    function Query(stream, store, Data, res, master) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.master = master;
    }

    Query.prototype.readyQuery = function() {
      $('#ResTbl').empty();
      $('#ResTbl').append(this.resvHead());
      this.resvSortClick('RHBooked', 'booked');
      this.resvSortClick('RHRoom', 'roomId');
      this.resvSortClick('RHArrive', 'arrive');
      this.resvSortClick('RHStayTo', 'stayto');
      this.resvSortClick('RHName', 'last');
      this.resvSortClick('RHStatus', 'status');
    };

    Query.prototype.updateBody = function(beg, end, prop) {
      var resvs;
      $('#QArrive').text(this.Data.toMMDD(beg));
      $('#QStayTo').text(this.Data.toMMDD(end));
      resvs = {};
      if (end != null) {
        resvs = this.res.resvArrayByProp(beg, end, prop);
      } else {
        resvs = this.res.resvArrayByDate(beg);
      }
      return this.resvBody(resvs);
    };

    Query.prototype.resvSortClick = function(id, prop) {
      return $('#' + id).click((function(_this) {
        return function() {
          return _this.resvBody(_this.res.resvArrayByProp(_this.master.dateBeg, _this.master.dateEnd, prop));
        };
      })(this));
    };

    Query.prototype.resvHead = function() {
      var htm;
      htm = "";
      htm += "<table class=\"RTTable\"><thead><tr>";
      htm += "<th id=\"RHArrive\">Arrive</th><th id=\"RHStayTo\">Stay To</th><th id=\"RHNights\">Nights</th><th id=\"RHRoom\"  >Room</th>";
      htm += "<th id=\"RHName\"  >Name</th>  <th id=\"RHGuests\">Guests</th> <th id=\"RHStatus\">Status</th><th id=\"RHBooked\">Booked</th>";
      htm += "<th id=\"RHPrice\" >Price</th> <th id=\"RHTotal\" >Total</th>  <th id=\"RHTax\"   >Tax</th>   <th id=\"RHCharge\">Charge</th>";
      htm += "</tr><tr>";
      htm += "<th id=\"QArrive\"></th><th id=\"QStayTo\"></th><th></th><th></th>";
      htm += "<th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th>";
      htm += "</tr></thead><tbody id=\"RTBody\"></tbody></table>";
      return htm;
    };

    Query.prototype.resvBody = function(resvs) {
      var arrive, booked, charge, htm, i, len, r, stayto, tax, trClass;
      $('#RTBody').empty();
      htm = "";
      for (i = 0, len = resvs.length; i < len; i++) {
        r = resvs[i];
        arrive = this.Data.toMMDD(r.arrive);
        stayto = this.Data.toMMDD(r.stayto);
        booked = this.Data.toMMDD(r.booked);
        tax = Util.toFixed(r.total * this.Data.tax);
        charge = Util.toFixed(r.total + parseFloat(tax));
        trClass = this.res.isNewResv(r) ? 'RTNewRow' : 'RTOldRow';
        htm += "<tr class=\"" + trClass + "\">";
        htm += "<td class=\"RTArrive\">" + arrive + "  </td><td class=\"RTStayto\">" + stayto + "</td><td class=\"RTNights\">" + r.nights + "</td>";
        htm += "<td class=\"RTRoomId\">" + r.roomId + "</td><td class=\"RTLast\"  >" + r.last + "</td><td class=\"RTGuests\">" + r.guests + "</td>";
        htm += "<td class=\"RTStatus\">" + r.status + "</td><td class=\"RTBooked\">" + booked + "</td><td class=\"RTPrice\" >$" + r.price + "</td>";
        htm += "<td class=\"RTTotal\" >$" + r.total + "</td><td class=\"RTTax\"   >$" + tax + "  </td><td class=\"RTCharge\">$" + charge + " </td></tr>";
      }
      return $('#RTBody').append(htm);
    };

    return Query;

  })();

}).call(this);