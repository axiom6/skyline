// Generated by CoffeeScript 1.12.2
(function() {
  var $, Credit,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $ = require('jquery');

  Credit = (function() {
    if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
      module.exports = Credit;
    }

    window.Credit = Credit;

    Credit.defaultFormat = /(\d{1,4})/g;

    Credit.UnknownCard = {
      type: 'Unknown',
      pattern: /^U/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    };

    function Credit() {
      this.formatCardExpiry = bind(this.formatCardExpiry, this);
      this.formatCardNumber = bind(this.formatCardNumber, this);
      this.parseCardType = bind(this.parseCardType, this);
      this.validateCardCVC = bind(this.validateCardCVC, this);
      this.validateCardExpiry = bind(this.validateCardExpiry, this);
      this.validateCardNumber = bind(this.validateCardNumber, this);
      this.parseCardExpiry = bind(this.parseCardExpiry, this);
      this.numericInput = bind(this.numericInput, this);
      this.cardNumberInput = bind(this.cardNumberInput, this);
      this.expiryInput = bind(this.expiryInput, this);
      this.cvcInput = bind(this.cvcInput, this);
      this.restrictCVCIp = bind(this.restrictCVCIp, this);
      this.restrictExpiryIp = bind(this.restrictExpiryIp, this);
      this.restrictCardNumberIp = bind(this.restrictCardNumberIp, this);
      this.restrictNumericIp = bind(this.restrictNumericIp, this);
      this.reFormatCVCIp = bind(this.reFormatCVCIp, this);
      this.formatBackExpiryIp = bind(this.formatBackExpiryIp, this);
      this.formatForwardSlashAndSpaceIp = bind(this.formatForwardSlashAndSpaceIp, this);
      this.formatForwardExpiryIp = bind(this.formatForwardExpiryIp, this);
      this.formatCardExpiryIp = bind(this.formatCardExpiryIp, this);
      this.reFormatExpiryIp = bind(this.reFormatExpiryIp, this);
      this.formatBackCardNumberIp = bind(this.formatBackCardNumberIp, this);
      this.formatCardNumberIp = bind(this.formatCardNumberIp, this);
      this.reFormatCardNumberIp = bind(this.reFormatCardNumberIp, this);
      this.replaceFullWidthChars = bind(this.replaceFullWidthChars, this);
      this.eventNormalize = bind(this.eventNormalize, this);
      this.fieldStatus = bind(this.fieldStatus, this);
      this.delay = 0;
    }

    Credit.prototype.init = function(numId, expId, cvcId, typId) {
      var cvc, exp, num, typ, updateType, validate, validateF;
      num = document.getElementById(numId);
      exp = document.getElementById(expId);
      cvc = document.getElementById(cvcId);
      typ = document.getElementById(typId);
      this.cardNumberInput(num);
      this.expiryInput(exp);
      this.cvcInput(cvc);
      updateType = (function(_this) {
        return function(e) {
          var cardType, msg;
          cardType = _this.parseCardType(e.target.value);
          msg = (cardType != null) && cardType !== '' ? cardType : '';
          typ.innerHTML = msg + ' Card Number';
        };
      })(this);
      num.addEventListener('input', updateType);
      validate = (function(_this) {
        return function(e) {
          var card, expiryObj;
          Util.noop(e);
          card = _this.cardFromNumber(num.value);
          expiryObj = _this.parseCardExpiry(exp.value);
          if (!_this.validateCardNumber(num.value)) {
            $('#er-num').show();
          }
          if (!_this.validateCardExpiry(expiryObj)) {
            $('#er-exp').show();
          }
          if (!_this.validateCardCVC(cvc.value, card.type)) {
            $('#er-exp').show();
          }
        };
      })(this);
      validateF = (function(_this) {
        return function(e) {
          var expiryObj, msg, valid;
          Util.noop(e);
          valid = [];
          expiryObj = _this.parseCardExpiry(exp.value);
          valid.push(_this.fieldStatus(num, _this.validateCardNumber(num.value)));
          valid.push(_this.fieldStatus(exp, _this.validateCardExpiry(expiryObj)));
          valid.push(_this.fieldStatus(cvc, _this.validateCardCVC(cvc.value, typ.innerHTML)));
          msg = valid.every(Boolean) ? 'valid' : 'invalid';
          res.innerHTML = msg;
          Util.log('Credit.init() validate', num.value, exp.value, cvc.value, msg);
        };
      })(this);
      return Util.noop(validateF);
    };

    Credit.prototype.fieldStatus = function(input, valid) {
      if (valid) {
        this.removeClass(input.parentNode, 'error');
      } else {
        this.addClass(input.parentNode, 'error');
      }
      return valid;
    };

    Credit.prototype.addClass = function(elem, klass) {
      if (elem.className.indexOf(klass) === -1) {
        elem.className += ' ' + klass;
      }
    };

    Credit.prototype.removeClass = function(elem, klass) {
      if (elem.className.indexOf(klass) !== -1) {
        elem.className = elem.className.replace(klass, '');
      }
    };

    Credit.prototype.cardFromNumber = function(num) {
      var card, i, len, ref;
      num = (num + '').replace(/\D/g, '');
      ref = Credit.cards;
      for (i = 0, len = ref.length; i < len; i++) {
        card = ref[i];
        if (card.pattern.test(num)) {
          return card;
        }
      }
      return Credit.UnknownCard;
    };

    Credit.prototype.cardFromType = function(type) {
      var card, i, len, ref;
      ref = Credit.cards;
      for (i = 0, len = ref.length; i < len; i++) {
        card = ref[i];
        if (card.type === type) {
          return card;
        }
      }
      return Credit.UnknownCard;
    };

    Credit.prototype.isCard = function(card) {
      return (card != null) && card.type !== 'Unknown';
    };

    Credit.prototype.getCaretPos = function(ele) {
      var r, rc, re;
      if (ele.selectionStart != null) {
        return ele.selectionStart;
      } else if (document.selection != null) {
        ele.focus();
        r = document.selection.createRange();
        re = ele.createTextRange();
        rc = re.duplicate();
        re.moveToBookmark(r.getBookmark());
        rc.setEndPoint('EndToStart', re);
        return rc.text.length;
      }
    };

    Credit.prototype.eventNormalize = function(listener) {
      return function(e) {
        if (e == null) {
          e = window.event;
        }
        e.target = e.target || e.srcElement;
        e.which = e.which || e.keyCode;
        if (e.preventDefault == null) {
          e.preventDefault = function() {
            return this.returnValue = false;
          };
        }
        return listener(e);
      };
    };

    Credit.prototype.doListen = function(ele, event, listener) {
      listener = this.eventNormalize(listener);
      if (ele.addEventListener != null) {
        return ele.addEventListener(event, listener, false);
      } else {
        return ele.attachEvent("on" + event, listener);
      }
    };

    Credit.cards = [
      {
        type: 'VisaElectron',
        pattern: /^4(026|17500|405|508|844|91[37])/,
        format: Credit.defaultFormat,
        length: [16],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Maestro',
        pattern: /^(5(018|0[23]|[68])|6(39|7))/,
        format: Credit.defaultFormat,
        length: [12, 13, 14, 15, 16, 17, 18, 19],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Forbrugsforeningen',
        pattern: /^600/,
        format: Credit.defaultFormat,
        length: [16],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Dankort',
        pattern: /^5019/,
        format: Credit.defaultFormat,
        length: [16],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Visa',
        pattern: /^4/,
        format: Credit.defaultFormat,
        length: [13, 16],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Mastercard',
        pattern: /^(5[1-5]|2[2-7])/,
        format: Credit.defaultFormat,
        length: [16],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Amex',
        pattern: /^3[47]/,
        format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/,
        length: [15],
        cvcLength: [3, 4],
        luhn: true
      }, {
        type: 'DinersClub',
        pattern: /^3[0689]/,
        format: /(\d{1,4})(\d{1,4})?(\d{1,4})?(\d{1,2})?/,
        length: [14],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'Discover',
        pattern: /^6([045]|22)/,
        format: Credit.defaultFormat,
        length: [16],
        cvcLength: [3],
        luhn: true
      }, {
        type: 'UnionPay',
        pattern: /^(62|88)/,
        format: Credit.defaultFormat,
        length: [16, 17, 18, 19],
        cvcLength: [3],
        luhn: false
      }, {
        type: 'JCB',
        pattern: /^35/,
        format: Credit.defaultFormat,
        length: [16],
        cvcLength: [3],
        luhn: true
      }
    ];

    Credit.prototype.luhnCheck = function(num) {
      var digit, digits, i, len, odd, sum;
      odd = true;
      sum = 0;
      digits = (num + '').split('').reverse();
      for (i = 0, len = digits.length; i < len; i++) {
        digit = digits[i];
        digit = parseInt(digit, 10);
        if ((odd = !odd)) {
          digit *= 2;
        }
        if (digit > 9) {
          digit -= 9;
        }
        sum += digit;
      }
      return sum % 10 === 0;
    };

    Credit.prototype.hasTextSelected = function(target) {
      var ref;
      if ((typeof document !== "undefined" && document !== null ? (ref = document.selection) != null ? ref.createRange : void 0 : void 0) != null) {
        if (document.selection.createRange().text) {
          return true;
        }
      }
      return (target.selectionStart != null) && target.selectionStart !== target.selectionEnd;
    };

    Credit.prototype.replaceFullWidthChars = function(str) {
      var char, chars, fullWidth, halfWidth, i, idx, len, value;
      if (str == null) {
        str = '';
      }
      if (!Util.isStr(str) || str === 'keypress') {
        Util.trace('replaceKeypress', str);
        return '';
      }
      fullWidth = '\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19';
      halfWidth = '0123456789';
      value = '';
      chars = str.split('');
      for (i = 0, len = chars.length; i < len; i++) {
        char = chars[i];
        idx = fullWidth.indexOf(char);
        if (idx > -1) {
          char = halfWidth[idx];
        }
        value += char;
      }
      return value;
    };

    Credit.prototype.reFormatCardNumberIp = function(e) {
      var cursor;
      cursor = this.getCaretPos(e.target);
      e.target.value = this.formatCardNumber(e.target.value);
      if ((cursor != null) && e.type !== 'change') {
        return e.target.setSelectionRange(cursor, cursor);
      }
    };

    Credit.prototype.formatCardNumberIp = function(e) {
      var card, cursor, digit, fn, length, re, upperLength, value;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      value = e.target.value;
      card = this.cardFromNumber(value + digit);
      length = (value.replace(/\D/g, '') + digit).length;
      upperLength = 16;
      if (this.isCard(card)) {
        upperLength = card.length[card.length.length - 1];
      }
      if (length >= upperLength) {
        return;
      }
      cursor = this.getCaretPos(e.target);
      if (cursor && cursor !== value.length) {
        return;
      }
      if (this.isCard(card) && card.type === 'amex') {
        re = /^(\d{4}|\d{4}\s\d{6})$/;
      } else {
        re = /(?:^|\s)(\d{4})$/;
      }
      if (re.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value + " " + digit;
        };
        return setTimeout(fn, this.delay);
      } else if (re.test(value + digit)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = (value + digit) + " ";
        };
        return setTimeout(fn, this.delay);
      }
    };

    Credit.prototype.formatBackCardNumberIp = function(e) {
      var cursor, fn, value;
      value = e.target.value;
      if (e.which !== 8) {
        return;
      }
      cursor = this.getCaretPos(e.target);
      if (cursor && cursor !== value.length) {
        return;
      }
      if (/\d\s$/.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value.replace(/\d\s$/, '');
        };
        return setTimeout(fn, this.delay);
      } else if (/\s\d?$/.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value.replace(/\d$/, '');
        };
        return setTimeout(fn, this.delay);
      }
    };

    Credit.prototype.reFormatExpiryIp = function(e) {
      var cursor;
      cursor = this.getCaretPos(e.target);
      e.target.value = this.formatCardExpiry(e.target.value);
      if ((cursor != null) && e.type !== 'change') {
        return e.target.setSelectionRange(cursor, cursor);
      }
    };

    Credit.prototype.formatCardExpiryIp = function(e) {
      var digit, fn, val;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      val = e.target.value + digit;
      if (/^\d$/.test(val) && (val !== '0' && val !== '1')) {
        e.preventDefault();
        fn = function() {
          return e.target.value = "0" + val + " / ";
        };
        return setTimeout(fn, this.delay);
      } else if (/^\d\d$/.test(val)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = val + " / ";
        };
        return setTimeout(fn, this.delay);
      }
    };

    Credit.prototype.formatForwardExpiryIp = function(e) {
      var digit, val;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      val = e.target.value;
      if (/^\d\d$/.test(val)) {
        return e.target.value = val + " / ";
      }
    };

    Credit.prototype.formatForwardSlashAndSpaceIp = function(e) {
      var val, which;
      which = String.fromCharCode(e.which);
      if (!(which === '/' || which === ' ')) {
        return;
      }
      val = e.target.value;
      if (/^\d$/.test(val) && val !== '0') {
        return e.target.value = "0" + val + " / ";
      }
    };

    Credit.prototype.formatBackExpiryIp = function(e) {
      var cursor, fn, value;
      value = e.target.value;
      if (e.which !== 8) {
        return;
      }
      cursor = this.getCaretPos(e.target);
      if (cursor && cursor !== value.length) {
        return;
      }
      if (/\d\s\/\s$/.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value.replace(/\d\s\/\s$/, '');
        };
        return setTimeout(fn, this.delay);
      }
    };

    Credit.prototype.reFormatCVCIp = function(e) {
      var cursor;
      cursor = this.getCaretPos(e.target);
      e.target.value = this.replaceFullWidthChars(e.target.value).replace(/\D/g, '').slice(0, 4);
      if ((cursor != null) && e.type !== 'change') {
        return e.target.setSelectionRange(cursor, cursor);
      }
    };

    Credit.prototype.restrictNumericIp = function(e) {
      var input;
      if (e.metaKey || e.ctrlKey) {
        return;
      }
      if (e.which === 0) {
        return;
      }
      if (e.which < 33) {
        return;
      }
      input = String.fromCharCode(e.which);
      if (!/^\d+$/.test(input)) {
        return e.preventDefault();
      }
    };

    Credit.prototype.restrictCardNumberIp = function(e) {
      var card, digit, value;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      if (this.hasTextSelected(e.target)) {
        return;
      }
      value = (e.target.value + digit).replace(/\D/g, '');
      card = this.cardFromNumber(value);
      if (this.isCard(card) && value.length > card.length[card.length.length - 1]) {
        return e.preventDefault();
      } else if (value.length > 16) {
        return e.preventDefault();
      }
    };

    Credit.prototype.restrictExpiryIp = function(e) {
      var digit, value;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      if (this.hasTextSelected(e.target)) {
        return;
      }
      value = e.target.value + digit;
      value = value.replace(/\D/g, '');
      if (value.length > 6) {
        return e.preventDefault();
      }
    };

    Credit.prototype.restrictCVCIp = function(e) {
      var digit, val;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      if (this.hasTextSelected(e.target)) {
        return;
      }
      val = e.target.value + digit;
      if (val.length > 4) {
        return e.preventDefault();
      }
    };

    Credit.prototype.cvcInput = function(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'keypress', this.restrictCVCIp);
      this.doListen(input, 'paste', this.reFormatCVCIp);
      this.doListen(input, 'change', this.reFormatCVCIp);
      return this.doListen(input, 'input', this.reFormatCVCIp);
    };

    Credit.prototype.expiryInput = function(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'keypress', this.restrictExpiryIp);
      this.doListen(input, 'keypress', this.formatCardExpiryIp);
      this.doListen(input, 'keypress', this.formatForwardSlashAndSpaceIp);
      this.doListen(input, 'keypress', this.formatForwardExpiryIp);
      this.doListen(input, 'keydown', this.formatBackExpiryIp);
      this.doListen(input, 'change', this.reFormatExpiryIp);
      return this.doListen(input, 'input', this.reFormatExpiryIp);
    };

    Credit.prototype.cardNumberInput = function(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'keypress', this.restrictCardNumberIp);
      this.doListen(input, 'keypress', this.formatCardNumberIp);
      this.doListen(input, 'keydown', this.formatBackCardNumberIp);
      this.doListen(input, 'paste', this.reFormatCardNumberIp);
      this.doListen(input, 'change', this.reFormatCardNumberIp);
      return this.doListen(input, 'input', this.reFormatCardNumberIp);
    };

    Credit.prototype.numericInput = function(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'paste', this.restrictNumericIp);
      this.doListen(input, 'change', this.restrictNumericIp);
      return this.doListen(input, 'input', this.restrictNumericIp);
    };

    Credit.prototype.parseCardExpiry = function(value) {
      var month, prefix, ref, year;
      value = value.replace(/\s/g, '');
      ref = value.split('/', 2), month = ref[0], year = ref[1];
      if ((year != null ? year.length : void 0) === 2 && /^\d+$/.test(year)) {
        prefix = (new Date).getFullYear();
        prefix = prefix.toString().slice(0, 2);
        year = prefix + year;
      }
      month = parseInt(month, 10);
      year = parseInt(year, 10);
      return {
        month: month,
        year: year
      };
    };

    Credit.prototype.validateCardNumber = function(num) {
      var card, ref;
      num = (num + '').replace(/\s+|-/g, '');
      if (!/^\d+$/.test(num)) {
        return false;
      }
      card = this.cardFromNumber(num);
      if (!this.isCard(card)) {
        return false;
      }
      return (ref = num.length, indexOf.call(card.length, ref) >= 0) && (card.luhn === false || this.luhnCheck(num));
    };

    Credit.prototype.validateCardExpiry = function(month, year) {
      var currentTime, expiry, ref;
      if (typeof month === 'object' && 'month' in month) {
        ref = month, month = ref.month, year = ref.year;
      }
      if (!(month && year)) {
        return false;
      }
      month = String(month).trim();
      year = String(year).trim();
      if (!/^\d+$/.test(month)) {
        return false;
      }
      if (!/^\d+$/.test(year)) {
        return false;
      }
      if (!((1 <= month && month <= 12))) {
        return false;
      }
      if (year.length === 2) {
        if (year < 70) {
          year = "20" + year;
        } else {
          year = "19" + year;
        }
      }
      if (year.length !== 4) {
        return false;
      }
      expiry = new Date(year, month);
      currentTime = new Date;
      expiry.setMonth(expiry.getMonth() - 1);
      expiry.setMonth(expiry.getMonth() + 1, 1);
      return expiry > currentTime;
    };

    Credit.prototype.validateCardCVC = function(cvc, type) {
      var card, ref;
      cvc = String(cvc).trim();
      if (!/^\d+$/.test(cvc)) {
        return false;
      }
      card = this.cardFromType(type);
      if (this.isCard(card)) {
        return ref = cvc.length, indexOf.call(card.cvcLength, ref) >= 0;
      } else {
        return cvc.length >= 3 && cvc.length <= 4;
      }
    };

    Credit.prototype.parseCardType = function(num) {
      var card;
      if (!num) {
        return '';
      }
      card = this.cardFromNumber(num);
      if (this.isCard(card)) {
        return card.type;
      } else {
        return '';
      }
    };

    Credit.prototype.formatCardNumber = function(num) {
      var card, groups, ref, upperLength;
      if (!Util.isStr(num)) {
        return '';
      }
      num = this.replaceFullWidthChars(num);
      num = num.replace(/\D/g, '');
      card = this.cardFromNumber(num);
      if (!this.isCard(card)) {
        return num;
      }
      upperLength = card.length[card.length.length - 1];
      num = num.slice(0, upperLength);
      if (card.format.global) {
        return (ref = num.match(card.format)) != null ? ref.join(' ') : void 0;
      } else {
        groups = card.format.exec(num);
        if (groups == null) {
          return;
        }
        groups.shift();
        groups = groups.filter(Boolean);
        return groups.join(' ');
      }
    };

    Credit.prototype.formatCardExpiry = function(expiry) {
      var mon, parts, sep, year;
      expiry = this.replaceFullWidthChars(expiry);
      parts = expiry.match(/^\D*(\d{1,2})(\D+)?(\d{1,4})?/);
      if (!parts) {
        return '';
      }
      mon = parts[1] || '';
      sep = parts[2] || '';
      year = parts[3] || '';
      if (year.length > 0) {
        sep = ' / ';
      } else if (sep === ' /') {
        mon = mon.substring(0, 1);
        sep = '';
      } else if (mon.length === 2 || sep.length > 0) {
        sep = ' / ';
      } else if (mon.length === 1 && (mon !== '0' && mon !== '1')) {
        mon = "0" + mon;
        sep = ' / ';
      }
      return mon + sep + year;
    };

    return Credit;

  })();

}).call(this);
