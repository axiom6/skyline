// Generated by CoffeeScript 1.12.2
(function() {
  var $, Credit, Pay,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Credit = require('js/res/Credit');

  Pay = (function() {
    module.exports = Pay;

    function Pay(stream, store, Data, res, home) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.res = res;
      this.home = home != null ? home : null;
      this.onError = bind(this.onError, this);
      this.onCharge = bind(this.onCharge, this);
      this.onToken = bind(this.onToken, this);
      this.onChargeError = bind(this.onChargeError, this);
      this.onTokenError = bind(this.onTokenError, this);
      this.submitPayment = bind(this.submitPayment, this);
      this.confirmEmailBody = bind(this.confirmEmailBody, this);
      this.onMakePayment = bind(this.onMakePayment, this);
      this.onMakeDeposit = bind(this.onMakeDeposit, this);
      this.onCancel = bind(this.onCancel, this);
      this.onChangeReser = bind(this.onChangeReser, this);
      this.initCCPayment = bind(this.initCCPayment, this);
      this.initPayResv = bind(this.initPayResv, this);
      this.credit = new Credit();
      this.uri = "https://api.stripe.com/v1/";
      this.subscribe();
      $.ajaxSetup({
        headers: {
          "Authorization": this.Data.stripeCurlKey
        }
      });
      this.resv = null;
      this.amount = 0;
      this.purpose = 'PayInFull';
      this.testing = false;
      this.errored = false;
    }

    Pay.prototype.initPayResv = function(totals, cust, rooms) {
      this.resv = this.res.createRoomResv('mine', 'card', totals, cust, rooms);
      this.amount = totals - this.resv.paid;
      $('#Pays').empty();
      $('#Pays').append(this.confirmHead(this.resv));
      $('#ConfirmBlock').append(this.confirmTable(this.resv, 'Guest'));
      $('#Pays').append(this.confirmBtns(this.resv));
      $('#PayDiv').append(this.payHtml());
      $('#Pays').append(this.termsHtml());
      this.initCCPayment(this.resv, this.amount);
      this.credit.init('cc-num', 'cc-exp', 'cc-cvc', 'cc-com');
      $('#Pays').show();
      if (this.testing) {
        this.testPop();
      }
    };

    Pay.prototype.initCCPayment = function(resv, amount) {
      this.hideCCErrors();
      $('#cc-amt').text('$' + amount);
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
      $('#er-sub').hide();
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
      if (this.home != null) {
        this.home.onHome();
      }
    };

    Pay.prototype.calcDeposit = function() {
      return Math.round(this.resv.totals * 50) / 100;
    };

    Pay.prototype.onMakeDeposit = function(e) {
      e.preventDefault();
      this.amount = this.ccAmt('Deposit');
      return $('#MakePay').text('Make 50% Deposit');
    };

    Pay.prototype.onMakePayment = function(e) {
      e.preventDefault();
      this.amount = this.ccAmt('PayInFull');
      return $('#MakePay').text('Make Payment with Visa Mastercard or Discover');
    };

    Pay.prototype.ccAmt = function(purpose) {
      var amount;
      if (purpose == null) {
        purpose = this.purpose;
      }
      this.purpose = purpose;
      amount = this.purpose === 'Deposit' ? this.calcDeposit() : this.resv.totals;
      $("#cc-amt").text('$' + amount);
      return amount;
    };

    Pay.prototype.confirmHead = function(resv) {
      var htm;
      console.log('Pay.confirmHead', resv);
      htm = "<div id=\"ConfirmTitle\" class= \"Title\"><span>Confirmation # " + resv.resId + "</span><span>  For: " + resv.cust.first + " </span><span>" + resv.cust.last + " </span></div>";
      htm += "<div id=\"ConfirmBlock\" class=\"DivCenter\"></div>";
      return htm;
    };

    Pay.prototype.confirmTable = function(resv, appName) {
      var htm;
      htm = "";
      htm += this.confirmRooms(resv, appName);
      htm += this.confirmPayments(resv);
      return htm;
    };

    Pay.prototype.confirmRooms = function(resv, appName) {
      var arrive, arriveTimes, days, depart, departTimes, htm, r, ref, roomId;
      htm = "<table id=\"ConfirmTable\"><thead>";
      htm += "<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th><th class=\"arrive\">Arrive</th><th class=\"depart\">Depart</th><th>Nights</th><th>Total</th></tr>";
      htm += "</thead><tbody>";
      arriveTimes = appName === 'Guest' ? "Arrival is from 3:00-8:00PM" : "";
      departTimes = appName === 'Guest' ? "Checkout is before 10:00AM" : "";
      ref = resv.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        r = ref[roomId];
        days = Util.keys(r.days).sort();
        arrive = this.confirmDate(days[0], "", false);
        depart = this.confirmDate(days[days.length - 1], "", true);
        htm += "<tr><td class=\"td-left\">" + r.name + "</td><td class=\"guests\">" + r.guests + "</td><td class=\"pets\">" + r.pets + "</td><td>" + (this.spa(resv, roomId)) + "</td><td class=\"room-price\">$" + r.price + "</td><td>" + arrive + "</td><td>" + depart + "</td><td class=\"nights\">" + r.nights + "</td><td id=\"" + roomId + "TR\" class=\"room-total\">$" + r.total + "</td></tr>";
      }
      htm;
      htm += "<tr><td></td><td></td><td></td><td></td><td></td><td class=\"arrive-times\">" + arriveTimes + "</td><td class=\"depart-times\">" + departTimes + "</td><td></td><td  id=\"TT\" class=\"room-total\">$" + resv.totals + "</td></tr>";
      return htm += "</tbody></table>";
    };

    Pay.prototype.confirmPayments = function(resv) {
      var date, htm, pay, payId, ref;
      htm = "<table id=\"ConfirmPayment\"><thead>";
      htm += "<tr><th>Amount</th><th>Purpose</th><th>Date</th><th>With</th><th>Last 4</th></tr>";
      htm += "</thead><tbody>";
      ref = resv.payments;
      for (payId in ref) {
        if (!hasProp.call(ref, payId)) continue;
        pay = ref[payId];
        date = this.confirmDate(pay.date, "", false);
        htm += "<tr><td>$" + pay.amount + "</td><td>" + pay.purpose + "</td><td>" + date + "</td><td>" + pay["with"] + "</td><td>" + pay.num + "</td></tr>";
      }
      htm += "</tbody></table>";
      htm += "<table id=\"ConfirmBalance\" style=\"margin-top:20px;\"><thead>";
      htm += "<tr><th>Total</th><th>Paid</th><th>Balance</th></tr>";
      htm += "</thead><tbody>";
      htm += "<tr><td>$" + resv.totals + "</td><td>$" + resv.paid + "</td><td>$" + resv.balance + "</td></tr>";
      htm += "</tbody></table>";
      return htm;
    };

    Pay.prototype.confirmEmail = function(resv) {
      var win;
      win = window.open("mailto:" + resv.cust.email + "?subject=Skyline Cottages Confirmation&body=" + (this.confirmEmailBody(resv)), "EMail");
      Util.noop(win);
    };

    Pay.prototype.confirmEmailBody = function(resv) {
      var body;
      body = "\n      Confirmation #" + resv.resId + "\nFor: " + resv.cust.first + " " + resv.cust.last + "\nPhone: " + resv.cust.phone + "\n\n";
      body += this.confirmEmailRooms(resv);
      body += "\n Totals:$" + resv.totals + " Paid:$" + resv.paid + " Balance:$" + resv.balance + " ";
      body = escape(body);
      return body;
    };

    Pay.prototype.confirmEmailRooms = function(resv) {
      var arrive, days, depart, name, r, ref, roomId, text;
      text = "";
      ref = resv.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        r = ref[roomId];
        name = Util.padEnd(r.name + ' ', 26, '-');
        days = Util.keys(r.days).sort();
        arrive = this.confirmDate(days[0], "", false);
        depart = this.confirmDate(days[days.length - 1], "", true);
        text += name + " $" + r.price + "  " + r.guests + "-Guests " + r.pets + "-Pets Arrive:" + arrive + " Depart:" + depart + " " + r.nights + "-Nights $" + r.total + "\n";
      }
      return text;
    };

    Pay.prototype.confirmContent2 = function(resv, stuff) {
      var arrive, bday, content, days, depart, eday, i, name, r, ref, roomId;
      content = "";
      Util.log('Pay.confirmContent rooms', resv.rooms);
      ref = resv.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        r = ref[roomId];
        name = Util.padEnd(r.name + ' ', 26, '-');
        days = Util.keys(r.days).sort();
        bday = days[0];
        i = 0;
        while (i < r.nights) {
          eday = days[i];
          if (i === r.nights - 1 || days[i + 1] !== this.Data.advanceDate(eday, 1)) {
            arrive = this.confirmDate(bday, "", false);
            depart = this.confirmDate(eday, "", true);
            if (stuff === 'html') {
              content += "<tr><td class=\"td-left\">" + r.name + "</td><td class=\"guests\">" + r.guests + "</td><td class=\"pets\">" + r.pets + "</td><td>" + (this.spa(resv, roomId)) + "</td><td class=\"room-price\">$" + r.price + "</td><td>" + arrive + "</td><td>" + depart + "</td><td class=\"nights\">" + r.nights + "</td><td id=\"" + roomId + "TR\" class=\"room-total\">$" + r.total + "</td></tr>";
            } else if (stuff === 'body') {
              content += name + " $" + r.price + "  " + r.guests + "-Guests " + r.pets + "-Pets Arrive:" + arrive + " Depart:" + depart + " " + r.nights + "-Nights $" + r.total + "\n";
            }
            bday = days[i + 1];
          }
          i++;
        }
      }
      return content;
    };

    Pay.prototype.spa = function(resv, roomId) {
      var change, has;
      change = resv.rooms[roomId].change;
      has = this.res.hasSpa(roomId);
      if (!has) {
        return '';
      } else if (change === -20) {
        return 'N';
      } else {
        return 'Y';
      }
    };

    Pay.prototype.confirmBtns = function(resv) {
      var canDeposit, htm;
      canDeposit = this.canMakeDeposit(resv);
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

    Pay.prototype.canMakeDeposit = function(resv) {
      var advance, arrive;
      arrive = parseInt(resv.arrive);
      advance = parseInt(this.Data.advanceDate(resv.booked, 7));
      return arrive >= advance;
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
      year = parseInt(dayStr.substr(0, 2)) + 2000;
      monthIdx = parseInt(dayStr.substr(2, 2)) - 1;
      day = parseInt(dayStr.substr(4, 2));
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
      num = $('#cc-num').val().toString();
      exp = $('#cc-exp').val().toString();
      cvc = $('#cc-cvc').val().toString();
      this.last4 = num.substr(11, 4);
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
      this.memToken("tokens", 'post', input, this.onTokenError);
    };

    Pay.prototype.charge = function(token, amount, currency, description) {
      var input;
      input = {
        source: token,
        amount: amount,
        currency: currency,
        description: description
      };
      this.memCharge("charges", 'post', input, this.onChargeError);
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
      return this.charge(this.tokenId, this.amount, 'usd', this.resv.cust.first + " " + this.resv.cust.last);
    };

    Pay.prototype.memToken = function(table, op, input, onError) {
      var result;
      result = {
        id: "tokenId",
        card: {
          id: "cardId"
        }
      };
      this.stream.publish(table, result);
    };

    Pay.prototype.memCharge = function(table, op, input, onError) {
      var result;
      result = {
        outcome: {
          type: "authorized"
        }
      };
      this.stream.publish(table, result);
    };

    Pay.prototype.onCharge = function(obj) {
      if (obj['outcome'].type === 'authorized') {
        this.doPost(this.resv);
        return this.res.postResv(this.resv, 'post', this.amount, 'Credit', this.last4, this.purpose);
      } else {
        this.amount = 0;
        this.doDeny(this.resv);
        return this.res.postResv(this.resv, 'deny', this.amount, 'Credit', this.last4, this.purpose);
      }
    };

    Pay.prototype.doPost = function(resv) {
      this.hidePay();
      $('#Approval').text("Approved: A Confirnation Email Been Sent To " + resv.cust.email);
      if (this.home != null) {
        return this.home.showConfirm();
      }
    };

    Pay.prototype.doDeny = function(resv) {
      this.showPay();
      return $('#Approval').text('Payment Denied').show();
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
      return "<ul class=\"Terms\">\n  <li>The number of guests and pets has to be declared in the reservation.</li>\n  <li>Prices have been automatically calculated.</li>\n  <li style=\"margin-left:20px;\">Additional guests are $10 per night above the base rate for 2-4 guests.</li>\n  <li style=\"margin-left:20px;\">Each pet is $12 per night.</li>\n  <li>A deposit is 50% of the total reservation.</li>\n  <li>There will be a deposit refund with a 50-day cancellation notice, less a $50 fee.</li>\n  <li>Less than 50-day notice, deposit is forfeited.</li>\n  <li>Short term reservations have a 3-day cancellation deadline.</li>\n</ul>";
    };

    return Pay;

  })();

}).call(this);
