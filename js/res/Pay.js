// Generated by CoffeeScript 1.12.2
(function() {
  var $, Data, Pay,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Data = require('js/res/Data');

  Pay = (function() {
    module.exports = Pay;

    function Pay(stream, store, room, cust, res) {
      this.stream = stream;
      this.store = store;
      this.room = room;
      this.cust = cust;
      this.res = res;
      this.onError = bind(this.onError, this);
      this.onCharge = bind(this.onCharge, this);
      this.onToken = bind(this.onToken, this);
      this.submitPayment = bind(this.submitPayment, this);
      this.initPayment = bind(this.initPayment, this);
      this.onBack = bind(this.onBack, this);
      this.uri = "https://api.stripe.com/v1/";
      this.subscribe();
      $.ajaxSetup({
        headers: {
          "Authorization": Data.stripeCurlKey
        }
      });
      this.myRes = {};
      this.created = false;
    }

    Pay.prototype.showConfirmPay = function(myRes) {
      this.myRes = myRes;
      if (this.created) {
        $('#Confirms').remove();
        $('#Confirm').prepend(this.confirmHtml(this.myRes));
        return $('#form-pay').show();
      } else {
        $('#Confirm').append(this.confirmHtml(this.myRes));
        $('#Confirm').append(this.payHtml());
        window.$ = $;
        Util.loadScript("../js/res/payment.js", this.initPayment);
        $('#cc-amt').text('$' + myRes.total);
        $('#cc-bak').click((function(_this) {
          return function(e) {
            return _this.onBack(e);
          };
        })(this));
        return this.created = true;
      }
    };

    Pay.prototype.onBack = function(e) {
      e.preventDefault();
      $('#Confirms').hide();
      $('#form-pay').hide();
      $('#Inits').show();
      $('#Rooms').show();
      $('#MakeRes').show();
    };

    Pay.prototype.confirmHtml = function(myRes) {
      var arrive, days, depart, htm, num, r, ref, roomId;
      htm = "<table id=\"Confirms\"><thead>";
      htm += "<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Price</th><th class=\"arrive\">Arrive</th><th class=\"depart\">Depart</th><th>Nights</th><th>Total</th></tr>";
      htm += "</thead><tbody>";
      ref = myRes.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        r = ref[roomId];
        days = Object.keys(r.days).sort();
        num = days.length;
        arrive = this.confirmDate(days[0], "", false);
        depart = this.confirmDate(days[num - 1], "", true);
        htm += "<tr><td>" + r.name + "</td><td class=\"guests\">" + r.guests + "</td><td class=\"pets\">" + r.pets + "</td><td class=\"room-price\">$" + r.price + "</td><td>" + arrive + "</td><td>" + depart + "</td><td class=\"nights\">" + num + "</td><td class=\"room-total\">$" + r.total + "</td></tr>";
      }
      htm += "<tr><td></td><td></td><td></td><td></td><td class=\"arrive-times\">Arrival is from 3:00-8:00PM</td><td class=\"depart-times\">Checkout is before 10:00AM</td><td></td><td class=\"room-total\">$" + myRes.total + "</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Pay.prototype.departDate = function(monthI, dayI, weekdayI) {
      var dayO, monthO, weekdayO;
      dayO = dayI + 1;
      monthO = monthI;
      weekdayO = (weekdayI + 1) % 7;
      if (dayI >= Data.numDayMonth[monthI]) {
        dayO = 1;
        monthO = monthI + 1;
      }
      return [monthO, dayO, weekdayO];
    };

    Pay.prototype.confirmDate = function(dayStr, msg, isDepart) {
      var day, monthIdx, ref, weekdayIdx, year;
      year = parseInt(dayStr.substr(0, 4));
      monthIdx = parseInt(dayStr.substr(4, 2)) - 1;
      day = parseInt(dayStr.substr(6, 2));
      weekdayIdx = new Date(year, monthIdx, day).getDay();
      if (isDepart) {
        ref = this.departDate(monthIdx, day, weekdayIdx), monthIdx = ref[0], day = ref[1], weekdayIdx = ref[2];
      }
      return Data.weekdays[weekdayIdx] + " " + Data.months[monthIdx] + " " + day + ", " + year + "  " + msg;
    };

    Pay.prototype.payHtml = function() {
      return "<form novalidate autocomplete=\"on\" method=\"POST\" id=\"form-pay\">\n\n    <span class=\"form-group\">\n      <label for=\"cc-num\" class=\"control-label\">Card Number<span class=\"text-muted\">  [<span class=\"cc-com\"></span>]</span></label>\n      <input id= \"cc-num\" type=\"tel\" class=\"input-lg form-control cc-num\" autocomplete=\"cc-num\" placeholder=\"•••• •••• •••• ••••\" required>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-exp\" class=\"control-label\">Expiration</label>\n      <input id= \"cc-exp\" type=\"tel\" class=\"input-lg form-control cc-exp\" autocomplete=\"cc-exp\" placeholder=\"mm / yy\" required>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-cvc\" class=\"control-label\">CVC</label>\n      <input id= \"cc-cvc\" type=\"tel\" class=\"input-lg form-control cc-cvc\" autocomplete=\"off\" placeholder=\"•••\" required>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-amt\"   class=\"control-label\">Amount</label>\n      <div  id= \"cc-amt\" class=\"input-lg form-control cc-amt\"></div>\n    </span>\n\n    <span class=\"form-group\">\n      <label class=\"control-label\">&nbsp;</label>\n      <button type=\"submit\" class=\"btn btn-lg btn-primary\" id=\"cc-sub\">Pay</button>\n    </span>\n\n    <span class=\"form-group\">\n      <label class=\"control-label\">&nbsp;</label>\n      <button class=\"btn btn-lg btn-primary\" id=\"cc-bak\">Go Back</button>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-msg\"   class=\"control-label\">Message</label>\n      <div  id= \"cc-msg\" class=\"input-lg form-control cc-msg\"></div>\n    </span>\n</form>";
    };

    Pay.prototype.toggleInputError = function(field, status) {
      var text;
      text = (function() {
        switch (field) {
          case 'Num':
            return 'Invalid Card Number';
          case 'Exp':
            return 'Invalid Expiration';
          case 'CVC':
            return 'Invalid CVC';
          default:
            return '';
        }
      })();
      if (status) {
        $("#cc-msg").text(text);
      }
      return this;
    };

    Pay.prototype.initPayment = function() {
      $('.cc-num').payment('formatCardNumber');
      $('.cc-exp').payment('formatCardExpiry');
      $('.cc-cvc').payment('formatCardCVC');
      return $('form').submit((function(_this) {
        return function(e) {
          return _this.submitPayment(e);
        };
      })(this));
    };

    Pay.prototype.submitPayment = function(e) {
      var cardType, ref;
      e.preventDefault();
      cardType = $.payment.cardType($('.cc-num').val());
      this.toggleInputError('Num', !$.payment.validateCardNumber($('.cc-num').val()));
      this.toggleInputError('Exp', !$.payment.validateCardExpiry($('.cc-exp').payment('cardExpiryVal')));
      this.toggleInputError('CVC', !$.payment.validateCardCVC($('.cc-cvc').val(), cardType));
      $('.cc-com').text(cardType);
      $('.cc-msg').removeClass('text-danger text-success');
      $('.cc-msg').addClass((ref = $('.has-error').length) != null ? ref : {
        'text-danger': 'text-success'
      });
      $('#cc-sub').text("Approved");
    };

    Pay.prototype.subscribe = function() {
      this.stream.subscribe('tokens', this.onToken, this.onError);
      return this.stream.subscribe('charges', this.onCharge, this.onError);
    };

    Pay.prototype.token = function(number, exp_month, exp_year, cvc) {
      var input;
      input = {
        "card[number]": number,
        "card[exp_month]": exp_month,
        "card[exp_year]": exp_year,
        "card[cvc]": cvc
      };
      return this.ajaxRest("tokens", 'post', input);
    };

    Pay.prototype.charge = function(token, amount, currency, description) {
      var input;
      input = {
        source: token,
        amount: amount,
        currency: currency,
        description: description
      };
      return this.ajaxRest("charges", 'post', input);
    };

    Pay.prototype.onToken = function(obj) {
      Util.log('StoreRest.onToken()', obj);
      this.token = obj.id;
      this.cardId = obj.card.id;
      return this.charge(this.token, 800, 'usd', 'First Test Charge');
    };

    Pay.prototype.onCharge = function(obj) {
      return Util.log('StoreRest.onCharge()', obj);
    };

    Pay.prototype.onError = function(obj) {
      return Util.error('StoreRest.onError()', obj);
    };

    Pay.prototype.ajaxRest = function(table, op, input) {
      var settings, url;
      url = this.uri + table;
      settings = {
        url: url,
        type: op
      };
      settings.headers = {
        Authorization: 'Bearer ' + Data.stripeTestKey
      };
      settings.data = input;
      settings.success = (function(_this) {
        return function(result, status, jqXHR) {
          _this.stream.publish(table, result);
          return Util.noop(jqXHR, status);
        };
      })(this);
      settings.error = (function(_this) {
        return function(jqXHR, status, error) {
          Util.error('StoreRest.ajaxRest()', {
            status: status,
            error: error
          });
          return Util.noop(jqXHR);
        };
      })(this);
      $.ajax(settings);
    };

    Pay.prototype.toQuery = function(input) {
      var key, query, val;
      query = "";
      if (input == null) {
        return query;
      }
      for (key in input) {
        if (!hasProp.call(input, key)) continue;
        val = input[key];
        query += "@" + key + "=" + val;
      }
      return query[0] = '?';
    };

    Pay.prototype.toJSON = function(obj) {
      if (obj != null) {
        return JSON.stringify(obj);
      } else {
        return '';
      }
    };

    Pay.prototype.toObject = function(json) {
      if (json) {
        return JSON.parse(json);
      } else {
        return {};
      }
    };

    return Pay;

  })();

}).call(this);
