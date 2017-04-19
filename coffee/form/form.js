(function() {

  var ccnum = document.getElementById('ccnum'),
    type    = document.getElementById('ccnum-type'),
    expiry  = document.getElementById('expiry'),
    cvc     = document.getElementById('cvc'),
    submit  = document.getElementById('submit'),
    result  = document.getElementById('result');

  var credit = new window.Credit();
  credit.cardNumberInput(ccnum);
  credit.expiryInput(expiry);
  credit.cvcInput(cvc);

  ccnum.addEventListener('input',   updateType);

  submit.addEventListener('click', function() {
    var valid     = [],
      expiryObj = credit.parseCardExpiry(expiry.value);

    valid.push(fieldStatus(ccnum,  credit.validateCardNumber(ccnum.value)));
    valid.push(fieldStatus(expiry, credit.validateCardExpiry(expiryObj)));
    valid.push(fieldStatus(cvc,    credit.validateCardCVC(cvc.value, type.innerHTML)));

    result.className = 'emoji ' + (valid.every(Boolean) ? 'valid' : 'invalid');
  });

  function updateType(e) {
    var cardType = credit.parseCardType(e.target.value);
    type.innerHTML = cardType || 'invalid';
  }


  function fieldStatus(input, valid) {
    if (valid) {
      removeClass(input.parentNode, 'error');
    } else {
      addClass(input.parentNode, 'error');
    }
    return valid;
  }

  function addClass(ele, _class) {
    if (ele.className.indexOf(_class) === -1) {
      ele.className += ' ' + _class;
    }
  }

  function removeClass(ele, _class) {
    if (ele.className.indexOf(_class) !== -1) {
      ele.className = ele.className.replace(_class, '');
    }
  }
})();