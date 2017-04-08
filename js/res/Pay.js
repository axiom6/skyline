// Generated by CoffeeScript 1.12.2
(function() {
  var $, Pay,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Pay = (function() {
    module.exports = Pay;

    function Pay(stream, store, room, cust, res, Data) {
      this.stream = stream;
      this.store = store;
      this.room = room;
      this.cust = cust;
      this.res = res;
      this.Data = Data;
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
          "Authorization": this.Data.stripeCurlKey
        }
      });
      this.myRes = {};
      this.created = false;
    }

    Pay.prototype.showConfirmPay = function(myRes) {
      this.myRes = myRes;
      if (this.created) {
        $('#ConfirmTitle').remove();
        $('#ConfirmTable').remove();
        $('#Confirm').prepend(this.confirmHtml(this.myRes));
        $('#cc-amt').text('$' + c);
        $('#form-pay').show();
        $('#Pays').show();
      } else {
        $('#Pays').append(this.confirmHtml(this.myRes));
        $('#Pays').append(this.payHtml());
        $('#Pays').show();
        window.$ = $;
        Util.loadScript("../js/res/payment.js", this.initPayment);
        $('#cc-amt').text('$' + myRes.total);
        $('#cc-bak').click((function(_this) {
          return function(e) {
            return _this.onBack(e);
          };
        })(this));
        this.created = true;
      }
    };

    Pay.prototype.onBack = function(e) {
      e.preventDefault();
      $('#Make').text('Change Reservation');
      $('#Pays').hide();
      $('#Book').show();
    };

    Pay.prototype.confirmHtml = function(myRes) {
      var arrive, days, depart, htm, num, r, ref, roomId;
      htm = "<div   id=\"ConfirmTitle\" class= \"Title\">Confirmation</div>";
      htm += "<table id=\"ConfirmTable\"><thead>";
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
      htm += "<div style=\"text-align:center;\"><button class=\"btn btn-primary\" id=\"cc-bak\">Change Reservation</button></div>";
      htm += "<div id=\"MakePay\" class=\"Title\">Make Payment</div>";
      return htm;
    };

    Pay.prototype.departDate = function(monthI, dayI, weekdayI) {
      var dayO, monthO, weekdayO;
      dayO = dayI + 1;
      monthO = monthI;
      weekdayO = (weekdayI + 1) % 7;
      if (dayI >= this.Data.numDayMonth[monthI]) {
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
      return this.Data.weekdays[weekdayIdx] + " " + this.Data.months[monthIdx] + " " + day + ", " + year + "  " + msg;
    };

    Pay.prototype.payHtml = function() {
      return "<div id=\"PayDiv\">\n  <form novalidate autocomplete=\"on\" method=\"POST\" id=\"form-pay\">\n\n    <span class=\"form-group\">\n      <label for=\"cc-num\" class=\"control-label\">Card Number<span class=\"text-muted\">  [<span class=\"cc-com\"></span>]</span></label>\n      <input id= \"cc-num\" type=\"tel\" class=\"input-lg form-control cc-num\" autocomplete=\"cc-num\" placeholder=\"•••• •••• •••• ••••\" required>\n      <div   id= \"er-num\" class=\"cc-msg\"></div>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-exp\" class=\"control-label\">Expiration</label>\n      <input id= \"cc-exp\" type=\"tel\" class=\"input-lg form-control cc-exp\" autocomplete=\"cc-exp\" placeholder=\"mm / yy\" required>\n      <div   id= \"er-exp\" class=\"cc-msg\"></div>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-cvc\" class=\"control-label\">CVC</label>\n      <input id= \"cc-cvc\" type=\"tel\" class=\"input-lg form-control cc-cvc\" autocomplete=\"off\" placeholder=\"•••\" required>\n      <div   id= \"er-cvc\" class=\"cc-msg\"></div>\n    </span>\n\n    <span class=\"form-group\">\n      <label for=\"cc-amt\"   class=\"control-label\">Amount</label>\n      <div   id= \"cc-amt\" class=\"input-lg form-control cc-amt\"></div>\n      <div   id= \"er-amt\" class=\"cc-msg\"></div>\n    </span>\n\n    <span class=\"form-group\">\n      <label  for=\"cc-sub\" class=\"control-label\">&nbsp;</label>\n      <button  id=\"cc-sub\" type=\"submit\" class=\"btn btn-lg btn-primary\">Pay</button>\n      <div    id= \"er-sub\" class=\"cc-msg\"></div>\n    </span>\n  </form>\n</div>\n<div id=\"Approval\"></div>";
    };

    Pay.prototype.toggleInputError = function(field, valid) {
      var msg;
      msg = '';
      if (!valid) {
        msg = (function() {
          switch (field) {
            case 'Num':
              return "Card Number?";
            case 'Exp':
              return "Expiration?";
            case 'CVC':
              return "CVC?";
          }
        })();
      }
      return msg;
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
      var cardType, cvc, cvcerr, exp, experr, mon, num, numerr, ref, yer;
      e.preventDefault();
      num = $('.cc-num').val();
      exp = $('.cc-exp').val();
      mon = exp.substr(0, 2);
      yer = '20' + exp.substr(5, 2);
      cvc = $('.cc-cvc').val();
      cardType = $.payment.cardType(num);
      numerr = this.toggleInputError('Num', $.payment.validateCardNumber($('.cc-num').val()));
      experr = this.toggleInputError('Exp', $.payment.validateCardExpiry($('.cc-exp').payment('cardExpiryVal')));
      cvcerr = this.toggleInputError('CVC', $.payment.validateCardCVC($('.cc-cvc').val(), cardType));
      $('.cc-com').text(cardType);
      $('.cc-msg').removeClass('text-danger text-success');
      $('.cc-msg').addClass((ref = $('.has-error').length) != null ? ref : {
        'text-danger': 'text-success'
      });
      if (numerr === '' && experr === '' && cvcerr === '') {
        $('#er-sub').text("Waiting For Approval");
        this.token(num, mon, yer, cvc);
      } else {
        $('#er-num').text(numerr);
        $('#er-exp').text(experr);
        $('#er-cvc').text(cvcerr);
        $('#er-sub').text("Fix?");
        $('#cc-sub').text("Try Again");
      }
      Util.log('Pay.submitPayment()', {
        num: num,
        exp: exp,
        cvc: cvc,
        mon: mon,
        yer: yer
      });
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
      this.ajaxRest("tokens", 'post', input);
    };

    Pay.prototype.charge = function(token, amount, currency, description) {
      var input;
      input = {
        source: token,
        amount: amount,
        currency: currency,
        description: description
      };
      this.ajaxRest("charges", 'post', input);
    };

    Pay.prototype.onToken = function(obj) {
      Util.log('StoreRest.onToken()', obj);
      this.tokenId = obj.id;
      this.cardId = obj.card.id;
      return this.charge(this.tokenId, this.myRes.total, 'usd', 'First Test Charge');
    };

    Pay.prototype.onCharge = function(obj) {
      Util.log('StoreRest.onCharge()', obj);
      if (obj.outcome.type === 'authorized') {
        $('#cc-bak').hide();
        $('#MakePay').hide();
        $('#PayDiv').hide();
        return $('#Approval').text('Approved: A Confirnation EMail Has Been Sent').show();
      } else {
        return $('#Approval').text('Denied').show();
      }
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
        Authorization: 'Bearer ' + this.Data.stripeTestKey
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
