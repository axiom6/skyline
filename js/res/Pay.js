// Generated by CoffeeScript 1.12.2
(function() {
  var $, Credit, Pay,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Credit = require('js/res/Credit');

  Pay = (function() {
    module.exports = Pay;

    function Pay(stream, store, room1, cust, res, home, Data) {
      this.stream = stream;
      this.store = store;
      this.room = room1;
      this.cust = cust;
      this.res = res;
      this.home = home;
      this.Data = Data;
      this.onError = bind(this.onError, this);
      this.onCharge = bind(this.onCharge, this);
      this.onToken = bind(this.onToken, this);
      this.onChargeError = bind(this.onChargeError, this);
      this.onTokenError = bind(this.onTokenError, this);
      this.submitPayment = bind(this.submitPayment, this);
      this.onMakePayment = bind(this.onMakePayment, this);
      this.onMakeDeposit = bind(this.onMakeDeposit, this);
      this.onCancel = bind(this.onCancel, this);
      this.onChangeReser = bind(this.onChangeReser, this);
      this.initCCPayment = bind(this.initCCPayment, this);
      this.showConfirmPay = bind(this.showConfirmPay, this);
      this.credit = new Credit();
      this.uri = "https://api.stripe.com/v1/";
      this.subscribe();
      $.ajaxSetup({
        headers: {
          "Authorization": this.Data.stripeCurlKey
        }
      });
      this.myRes = {};
      this.first = '';
      this.last = '';
      this.phone = '';
      this.email = '';
      this.spas = false;
      this.purpose = 'PayInFull';
      this.testing = true;
      this.errored = false;
    }

    Pay.prototype.showSpa = function(myRes) {
      var ref, room, roomId;
      ref = myRes.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        if (this.room.hasSpa(roomId)) {
          return true;
        }
      }
      return false;
    };

    Pay.prototype.showConfirmPay = function(myRes) {
      this.myRes = myRes;
      this.myRes['cust'] = this.cust.createCust(this.first, this.last, this.phone, this.email, 'site');
      $('#Pays').empty();
      $('#Pays').append(this.confirmHead());
      $('#ConfirmBlock').append(this.confirmTable());
      $('#Pays').append(this.confirmBtns());
      $('#PayDiv').append(this.payHtml());
      $('#Pays').append(this.termsHtml());
      this.initCCPayment();
      this.credit.init('cc-num', 'cc-exp', 'cc-cvc', 'cc-com');
      $('#Pays').show();
    };

    Pay.prototype.initCCPayment = function() {
      this.hideCCErrors();
      $('#cc-amt').text('$' + this.myRes.total);
      $('#ChangeReser').click((function(_this) {
        return function(e) {
          return _this.onChangeReser(e);
        };
      })(this));
      $('#MakeDeposit').click((function(_this) {
        return function(e) {
          return _this.onMakeDeposit(e);
        };
      })(this));
      $('#MakePayment').click((function(_this) {
        return function(e) {
          return _this.onMakePayment(e);
        };
      })(this));
      $('.SpaCheck').change((function(_this) {
        return function(e) {
          return _this.onSpa(e);
        };
      })(this));
      $('#cc-sub').click((function(_this) {
        return function(e) {
          return _this.submitPayment(e);
        };
      })(this));
      $('#cc-can').click((function(_this) {
        return function(e) {
          return _this.onCancel(e);
        };
      })(this));
    };

    Pay.prototype.hideCCErrors = function() {
      $('#er-num').text('Invalid Number');
      $('#er-num').hide();
      $('#er-exp').hide();
      $('#er-cvc').hide();
      return $('#er-sub').hide();
    };

    Pay.prototype.testPop = function() {
      $('#cc-num').val('4242424242424242');
      $('#cc-exp').val('10/19');
      $('#cc-cvc').val('555');
    };

    Pay.prototype.onChangeReser = function(e) {
      e.preventDefault();
      $('#Make').text('Change Reservation');
      $('#Pays').hide();
      $('#Book').show();
    };

    Pay.prototype.onCancel = function(e) {
      e.preventDefault();
      this.home.onHome();
    };

    Pay.prototype.onMakeDeposit = function(e) {
      e.preventDefault();
      this.purpose = 'Deposit';
      $("#cc-amt").text('$' + this.myRes.deposit);
      return $('#MakePay').text('Make 50% Deposit');
    };

    Pay.prototype.onMakePayment = function(e) {
      e.preventDefault();
      this.purpose = 'PayInFull';
      $("#cc-amt").text('$' + this.myRes.total);
      return $('#MakePay').text('Make Payment with Visa Mastercard or Discover');
    };

    Pay.prototype.ccAmt = function() {
      var amt;
      amt = this.purpose === 'Deposit' ? this.myRes.deposit : this.myRes.total;
      $("#cc-amt").text('$' + amt);
    };

    Pay.prototype.confirmHead = function() {
      var htm;
      htm = "<div id=\"ConfirmTitle\" class= \"Title\">Confirmation # " + this.myRes.key + "</div>";
      htm += "<div><div id=\"ConfirmName\"><span>For: " + this.first + " </span><span>" + this.last + " </span></div></div>";
      htm += "<div id=\"ConfirmBlock\" class=\"DivCenter\"></div>";
      return htm;
    };

    Pay.prototype.confirmTable = function() {
      var arrive, bday, days, depart, eday, htm, i, night, num, r, ref, roomId, spaTH, total;
      this.spas = this.showSpa(this.myRes);
      spaTH = this.spas ? "Spa" : "";
      htm = "<table id=\"ConfirmTable\"><thead>";
      htm += "<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>" + spaTH + "</th><th>Price</th><th class=\"arrive\">Arrive</th><th class=\"depart\">Depart</th><th>Nights</th><th>Total</th></tr>";
      htm += "</thead><tbody>";
      ref = this.myRes.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        r = ref[roomId];
        days = Object.keys(r.days).sort();
        num = days.length;
        bday = days[0];
        i = 0;
        total = 0;
        night = 0;
        while (i < num) {
          eday = days[i];
          total += r.price;
          night++;
          if (i === num - 1 || days[i + 1] !== this.Data.advanceDate(eday, 1)) {
            arrive = this.confirmDate(bday, "", false);
            depart = this.confirmDate(eday, "", true);
            htm += "<tr><td class=\"td-left\">" + r.name + "</td><td class=\"guests\">" + r.guests + "</td><td class=\"pets\">" + r.pets + "</td><td>" + (this.spa(roomId)) + "</td><td class=\"room-price\">$" + r.price + "</td><td>" + arrive + "</td><td>" + depart + "</td><td class=\"nights\">" + night + "</td><td id=\"" + roomId + "TR\" class=\"room-total\">$" + total + "</td></tr>";
            bday = days[i + 1];
            total = 0;
            night = 0;
          }
          i++;
        }
      }
      htm += "<tr><td></td><td></td><td></td><td></td><td></td><td class=\"arrive-times\">Arrival is from 3:00-8:00PM</td><td class=\"depart-times\">Checkout is before 10:00AM</td><td></td><td  id=\"TT\" class=\"room-total\">$" + this.myRes.total + "</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Pay.prototype.confirmBtns = function() {
      var canDeposit, htm;
      canDeposit = this.canMakeDeposit(this.myRes);
      htm = "<div class=\"PayBtns\">";
      htm += "  <button class=\"btn btn-primary\" id=\"ChangeReser\">Change Reservation</button>";
      if (canDeposit) {
        htm += "  <button class=\"btn btn-primary\" id=\"MakeDeposit\">Make 50% Deposit</button>";
      }
      if (canDeposit) {
        htm += "  <button class=\"btn btn-primary\" id=\"MakePayment\">Make Payment</button>";
      }
      htm += "</div>";
      htm += "<div id=\"MakePay\" class=\"Title\">Make Payment</div>";
      htm += "<div id=\"PayDiv\"></div>";
      htm += "<div id=\"Approval\"></div>";
      return htm;
    };

    Pay.prototype.canMakeDeposit = function(myRes) {
      return this.myRes.arrive >= this.Data.advanceDate(this.myRes.booked, 7);
    };

    Pay.prototype.spa = function(roomId) {
      if (this.room.hasSpa(roomId)) {
        return "<input id=\"" + roomId + "SpaCheck\" class=\"SpaCheck\" type=\"checkbox\" value=\"" + roomId + "\" checked>";
      } else {
        return "";
      }
    };

    Pay.prototype.onSpa = function(event) {
      var $elem, checked, roomId, spaFee;
      $elem = $(event.target);
      roomId = $elem.attr('id').charAt(0);
      checked = $elem.is(':checked');
      spaFee = checked ? 20 : -20;
      this.myRes.rooms[roomId].total += spaFee;
      this.myRes.total += spaFee;
      this.myRes.deposit += spaFee / 2;
      $('#' + roomId + 'TR').text('$' + this.myRes.rooms[roomId].total);
      $('#TT').text('$' + this.myRes.total);
      this.ccAmt();
    };

    Pay.prototype.confirmBody = function() {
      var arrive, bday, body, days, depart, eday, i, num, r, ref, room, roomId, total;
      body = ".      Confirmation# " + this.myRes.key + "\n";
      body += ".      For: " + this.first + " " + this.last + "\n";
      ref = this.myRes.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        r = ref[roomId];
        room = Util.padEnd(r.name, 24, '-');
        days = Object.keys(r.days).sort();
        num = days.length;
        bday = days[0];
        i = 1;
        total = r.price;
        while (i < num) {
          eday = days[i];
          if (i === num - 1 || eday !== this.Data.advance(eday, 1)) {
            arrive = this.confirmDate(bday, "", false);
            depart = this.confirmDate(days[num - 1], "", true);
            body += room + " $" + r.price + "  " + r.guests + "-Guests " + r.pets + "-Pets Arrive:" + arrive + " Depart:" + depart + " " + num + "-Nights $" + total + "\n";
          }
          i++;
        }
      }
      body += "\n.      Arrival is from 3:00-8:00PM   Checkout is before 10:00AM\n";
      body = escape(body);
      return body;
    };

    Pay.prototype.confirmEmail = function() {
      var win;
      win = window.open("mailto:" + this.email + "?subject=Skyline Cottages Confirmation&body=" + (this.confirmBody()), "EMail");
      if ((win != null) && !win.closed) {
        win.close();
      }
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
      var cvcPtn, expPtn, numPtn;
      numPtn = "\d{4} \d{4} \d{4} \d{4}";
      expPtn = "(1[0-2]|0[1-9])\/\d\d";
      cvcPtn = "\d{3}";
      return "<div id=\"form-pay\">\n  <span class=\"form-group\">\n    <label for=\"cc-num\" class=\"control-label\" id=\"cc-com\">Card Number</label>\n    <input id= \"cc-num\" type=\"tel\" class=\"input-lg form-control cc-num masked\" placeholder=\"•••• •••• •••• ••••\" pattern=\"" + numPtn + "\" required>\n    <div   id= \"er-num\" class=\"cc-msg\">Invalid Number</div>\n  </span>\n\n  <span class=\"form-group\">\n    <label for=\"cc-exp\" class=\"control-label\">MM/YY Expiration</label>\n    <input id= \"cc-exp\" type=\"tel\" class=\"input-lg form-control cc-exp masked\" placeholder=\"MM/YY\" pattern=\"" + expPtn + "\" required>\n    <div   id= \"er-exp\" class=\"cc-msg\">Invalid MM/YY</div>\n  </span>\n\n  <span class=\"form-group\">\n    <label for=\"cc-cvc\" class=\"control-label\">CVC</label>\n    <input id= \"cc-cvc\" type=\"tel\" class=\"input-lg form-control cc-cvc masked\" placeholder=\"•••\" pattern=\"" + cvcPtn + "\"  required>\n    <div   id= \"er-cvc\" class=\"cc-msg\">Invalid CVC</div>\n  </span>\n\n  <span class=\"form-group\">\n    <label for=\"cc-amt\"   class=\"control-label\">Amount</label>\n    <div   id= \"cc-amt\" class=\"input-lg form-control cc-amt\"></div>\n    <div   id= \"er-amt\" class=\"cc-msg\"></div>\n  </span>\n\n  <span class=\"form-group\">\n    <label  for=\"cc-sub\" class=\"control-label\">&nbsp;</label>\n    <button id= \"cc-sub\" class=\"btn btn-lg btn-primary\">Pay</button>\n    <div    id= \"er-sub\" class=\"cc-msg\"></div>\n  </span>\n\n  <span class=\"form-group\">\n    <label  for=\"cc-can\" class=\"control-label\">&nbsp;</label>\n    <button id= \"cc-can\" class=\"btn btn-lg btn-primary\">Cancel</button>\n    <div    id= \"er-can\" class=\"cc-msg\"></div>\n  </span>\n</div>";
    };

    Pay.prototype.submitPayment = function(e) {
      var accept, ae, card, ce, cvc, ee, exp, iry, mon, ne, num, yer;
      if (e != null) {
        e.preventDefault();
      }
      this.hideCCErrors();
      num = $('#cc-num').val();
      exp = $('#cc-exp').val();
      cvc = $('#cc-cvc').val();
      card = this.credit.cardFromNumber(num);
      iry = this.credit.parseCardExpiry(exp);
      accept = this.cardAccept(card.type);
      ne = this.credit.validateCardNumber(num);
      ee = this.credit.validateCardExpiry(iry);
      ce = this.credit.validateCardCVC(cvc, card.type);
      mon = exp.substr(0, 2);
      yer = '20' + exp.substr(5, 2);
      if (ne && ee && ce && accept) {
        this.hidePay();
        $('#Approval').text("Waiting For Approval...").show();
        this.token(num, mon, yer, cvc);
        this.last4 = num.substr(11, 4);
      } else {
        ae = card.type + ' not accepted';
        if (!accept) {
          $('#er-num').text(ae);
        }
        if (!ne || !accept) {
          $('#er-num').show();
        }
        if (!ee) {
          $('#er-exp').show();
        }
        if (!ce) {
          $('#er-cvc').show();
        }
      }
    };

    Pay.prototype.hidePay = function() {
      $('#MakePay').hide();
      $('#PayDiv').hide();
      return $('.PayBtns').hide();
    };

    Pay.prototype.showPay = function() {
      $('#MakePay').show();
      $('#PayDiv').show();
      return $('.PayBtns').show();
    };

    Pay.prototype.isValid = function(name, test, testing) {
      var valid, value;
      if (testing == null) {
        testing = false;
      }
      value = $('#' + name).val();
      valid = Util.isStr(value);
      if (testing) {
        $('#' + name).val(test);
        value = test;
        valid = true;
      }
      return [value, valid];
    };

    Pay.prototype.cardAccept = function(cardType) {
      return cardType === 'Visa' || cardType === 'Mastercard' || cardType === 'Discover';
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
      this.ajaxRest("tokens", 'post', input, this.onTokenError);
    };

    Pay.prototype.charge = function(token, amount, currency, description) {
      var input;
      input = {
        source: token,
        amount: amount,
        currency: currency,
        description: description
      };
      this.ajaxRest("charges", 'post', input, this.onChargeError);
    };

    Pay.prototype.onTokenError = function(error, status) {
      Util.noop(error, status);
      this.showPay();
      $('#Approval').text("Unable to Verify Card").show();
    };

    Pay.prototype.onChargeError = function(error, status) {
      Util.noop(error, status);
      this.showPay();
      $('#Approval').text("Payment Denied").show();
    };

    Pay.prototype.onToken = function(obj) {
      this.tokenId = obj.id;
      this.cardId = obj.card.id;
      return this.charge(this.tokenId, this.myRes.total, 'usd', this.first + " " + this.last);
    };

    Pay.prototype.onCharge = function(obj) {
      if (obj['outcome'].type === 'authorized') {
        this.confirmEmail();
        this.hidePay();
        $('#Approval').text("Approved: A Confirnation Email Been Sent To " + this.email);
        this.home.showConfirm();
        this.myRes.payments[this.payId()] = this.createPayment();
        return this.store.put('Res', this.myRes.key, this.myRes);
      } else {
        this.showPay();
        return $('#Approval').text('Payment Denied').show();
      }
    };

    Pay.prototype.payId = function() {
      var pays;
      pays = Object.keys(this.myRes.payments).sort();
      if (pays.length > 0) {
        return toString(parseInt(pays[pays.length - 1]) + 1);
      } else {
        return '1';
      }
    };

    Pay.prototype.createPayment = function() {
      var payment;
      payment = {};
      payment.amount = this.myRes.total;
      payment.date = this.Data.today();
      payment.method = 'card';
      payment["with"] = this.last4;
      payment.purpose = this.purpose;
      return payment;
    };

    Pay.prototype.onError = function(obj) {
      return Util.error('StoreRest.onError()', obj);
    };

    Pay.prototype.ajaxRest = function(table, op, input, onError) {
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
          Util.noop(jqXHR, status);
        };
      })(this);
      settings.error = (function(_this) {
        return function(jqXHR, status, error) {
          Util.noop(jqXHR);
          return onError(status, error);
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

    Pay.prototype.termsHtml = function() {
      return "<ul class=\"Terms\">\n  <li>Prices have been automatically calculated.</li>\n  <li>The number of guests and pets has to be declared in the reservation.</li>\n  <li>Pricing for 1-2 guests is the same for cottages 1 2 4 7 8 N S.</li>\n  <li>Pricing for 1-4 guests is the same for cottages 3 5 6.</li>\n  <li>Additional guests are $10 per night.</li>\n  <li>Each pet is $12 per night.</li>\n  <li>Deposit is 50% of total reservation.</li>\n  <li>There will be a deposit refund with a 50-day cancellation notice, less a $50 fee.</li>\n  <li>Less than 50-day notice, deposit is forfeited.</li>\n  <li>Short term reservations have a 3-day cancellation deadline.</li>\n</ul>";
    };

    return Pay;

  })();

}).call(this);
