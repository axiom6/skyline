
#$ = require('jquery')

class Credit

  module.exports = Credit
  window.Credit  = Credit

  @defaultFormat = /(\d{1,4})/g # new RegExp('(\d{1,4})', 'g') #  /(\d{1,4})/g

  constructor:() ->

  init:( numId, expId, cvcId, subId, typId, resId ) ->

    num = document.getElementById(numId)
    exp = document.getElementById(expId)
    cvc = document.getElementById(cvcId)
    sub = document.getElementById(subId)
    typ = document.getElementById(subId)
    res = document.getElementById(resId)

    @cardNumberInput( num )
    @expiryInput(     exp )
    @cvcInput(        cvc )

    updateType = (e) =>
      cardType = @parseCardType(e.target.value)
      msg      = cardType || 'invalid'
      typ.innerHTML = msg
      Util.log( 'Credit.init() updateType', num.value, exp.value, cvc.value, msg )
      return
    num.addEventListener( 'input', updateType )

    validate = (e) =>
      Util.noop( e )
      valid     = []
      expiryObj = @parseCardExpiry( exp.value )
      valid.push( @fieldStatus( num, @validateCardNumber( num.value ) ) )
      valid.push( @fieldStatus( exp, @validateCardExpiry( expiryObj ) ) )
      valid.push( @fieldStatus( cvc, @validateCardCVC( cvc.value, typ.innerHTML ) ) )
      msg = if valid.every(Boolean) then 'valid' else  'invalid'
      res.innerHTML = msg
      Util.log( 'Credit.init() validate', num.value, exp.value, cvc.value, msg )
      return
    sub.addEventListener('click', validate )


  fieldStatus:( input, valid ) =>
    if valid
      @removeClass( input.parentNode, 'error' )
    else
      @addClass(    input.parentNode, 'error' )
    valid

  addClass:( elem, klass) ->
    if elem.className.indexOf(klass) is -1
       elem.className += ' ' + klass
    return

  removeClass:( elem, klass ) ->
    if elem.className.indexOf(klass) isnt -1
       elem.className = elem.className.replace( klass, '' )
    return

  cardFromNumber: (num) ->
    num = (num + '').replace(/\D/g, '')
    ven = {}
    for card in Credit.cards when card.pattern.test(num)
      ven = card
      break
    #console.log( 'Credit.cardFromNumber()', ven.type, ven.format.toString(), num )
    ven

  cardFromType: (type) ->
    ven = {}
    for card in Credit.cards when card.type is type
      ven = card
      break
    #console.log( 'Credit.cardFromType()', type, ven.type, ven.format.toString(), num )
    ven
    
  getCaretPos: (ele) ->
    if ele.selectionStart?
      return ele.selectionStart
    else if document.selection?
      ele.focus()
      r = document.selection.createRange()
      re = ele.createTextRange()
      rc = re.duplicate()
      re.moveToBookmark(r.getBookmark())
      rc.setEndPoint('EndToStart', re)
      return rc.text.length

  eventNormalize:(listener) ->
    return (e = window.event) ->
      e.target = e.target or e.srcElement
      e.which = e.which or e.keyCode
      unless e.preventDefault?
        e.preventDefault = -> this.returnValue = false
      listener(e)

  listen:(ele, event, listener) ->
    listener = @eventNormalize(listener)
    if ele.addEventListener?
      ele.addEventListener(event, listener, false)
    else
      ele.attachEvent("on#{event}", listener)

  @cards = [
    # Debit cards must come first, since they have more
    # specific patterns than their credit-card equivalents.
    {
      type: 'visaelectron'
      pattern: /^4(026|17500|405|508|844|91[37])/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'maestro'
      pattern: /^(5(018|0[23]|[68])|6(39|7))/
      format: Credit.defaultFormat
      length: [12..19]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'forbrugsforeningen'
      pattern: /^600/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'dankort'
      pattern: /^5019/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    # Credit cards
    {
      type: 'visa'
      pattern: /^4/
      format: Credit.defaultFormat
      length: [13, 16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'mastercard'
      pattern: /^(5[1-5]|2[2-7])/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'amex'
      pattern: /^3[47]/
      format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/
      length: [15]
      cvcLength: [3..4]
      luhn: true
    }
    {
      type: 'dinersclub'
      pattern: /^3[0689]/
      format: /(\d{1,4})(\d{1,4})?(\d{1,4})?(\d{1,2})?/
      length: [14]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'discover'
      pattern: /^6([045]|22)/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'unionpay'
      pattern: /^(62|88)/
      format: Credit.defaultFormat
      length: [16..19]
      cvcLength: [3]
      luhn: false
    }
    {
      type: 'jcb'
      pattern: /^35/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
  ]

  luhnCheck:(num) ->
    odd = true
    sum = 0

    digits = (num + '').split('').reverse()

    for digit in digits
      digit = parseInt(digit, 10)
      digit *= 2 if (odd = !odd)
      digit -= 9 if digit > 9
      sum += digit

    sum % 10 == 0

  hasTextSelected:(target) ->
    # If some text is selected in IE
    if document?.selection?.createRange?
      return true if document.selection.createRange().text
    target.selectionStart? and target.selectionStart isnt target.selectionEnd

  # Private

  # Replace Full-Width Chars

  replaceFullWidthChars:( str="" ) ->
    fullWidth = '\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19'
    halfWidth = '0123456789'

    value = ''
    chars = if Util.isStr(str) then str.split('') else []

    for char in chars
      idx  = fullWidth.indexOf(char)
      char = halfWidth[idx] if idx > -1
      value += char

    value

  # Format Card Number

  reFormatCardNumber:(e) =>
    cursor = @getCaretPos(e.target)
    e.target.value = @formatCardNumber(e.target.value)
    if cursor? and e.type isnt 'change'
      e.target.setSelectionRange(cursor, cursor)

  formatCardNumber:(e) =>
    # Only format if input is a number
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    value  = e.target.value
    card   = @cardFromNumber(value + digit)
    length = (value.replace(/\D/g, '') + digit).length

    upperLength = 16
    upperLength = card.length[card.length.length - 1] if card
    return if length >= upperLength

    # Return if focus isn't at the end of the text
    cursor = @getCaretPos(e.target)
    return if cursor and cursor isnt value.length

    if card && card.type is 'amex'
      # AMEX cards are formatted differently
      re = /^(\d{4}|\d{4}\s\d{6})$/
    else
      re = /(?:^|\s)(\d{4})$/

    # If '4242' + 4
    fn  = () -> (e.target.value = "#{value} #{digit}")
    if re.test(value)
      e.preventDefault()
      setTimeout( fn, 1000  )

    # If '424' + 2
    else if re.test(value + digit)
      e.preventDefault()
      setTimeout( fn, 1000  )

  formatBackCardNumber:(e) =>
    value = e.target.value

    # Return unless backspacing
    return unless e.which is 8

    # Return if focus isn't at the end of the text
    cursor = @getCaretPos(e.target)
    return if cursor and cursor isnt value.length

    # Remove the digit + trailing space
    if /\d\s$/.test(value)
      e.preventDefault()
      fn = () -> e.target.value = value.replace /\d\s$/, ''
      setTimeout( fn, 1000  )
    # Remove digit if ends in space + digit
    else if /\s\d?$/.test(value)
      e.preventDefault()
      fn = () -> e.target.value = value.replace /\d$/, ''
      setTimeout( fn, 1000  )

  # Format Expiry

  reFormatExpiry:(e) =>
    cursor = @getCaretPos(e.target)
    e.target.value = @formatCardExpiry(e.target.value)
    if cursor? and e.type isnt 'change'
      e.target.setSelectionRange(cursor, cursor)

  formatCardExpiry:(e) =>
    # Only format if input is a number
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    val = e.target.value + digit
    fn  = () -> e.target.value = "0#{val} / "
    if /^\d$/.test(val) and val not in ['0', '1']
      e.preventDefault()
      setTimeout( fn, 1000 )

    else if /^\d\d$/.test(val)
      e.preventDefault()
      setTimeout( fn, 1000 )

  formatForwardExpiry:(e) =>
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)
    val = e.target.value
    if /^\d\d$/.test(val)
      e.target.value = "#{val} / "

  formatForwardSlashAndSpace:(e) =>
    which = String.fromCharCode(e.which)
    return unless which is '/' or which is ' '
    val = e.target.value
    if /^\d$/.test(val) and val isnt '0'
      e.target.value = "0#{val} / "

  formatBackExpiry:(e) =>
    value = e.target.value

    # Return unless backspacing
    return unless e.which is 8

    # Return if focus isn't at the end of the text
    cursor = @getCaretPos(e.target)
    return if cursor and cursor isnt value.length

    # Remove the trailing space + last digit
    if /\d\s\/\s$/.test(value)
      e.preventDefault()
      fn = () -> e.target.value = value.replace(/\d\s\/\s$/, '')
      setTimeout( fn, 1000 )

  # Format CVC

  reFormatCVC:(e) =>
    cursor = @getCaretPos(e.target)
    e.target.value = @replaceFullWidthChars(e.target.value).replace(/\D/g, '')[0...4]
    if cursor? and e.type isnt 'change'
      e.target.setSelectionRange(cursor, cursor)

  # Restrictions

  restrictNumeric:(e) =>
    # Key event is for a browser shortcut
    return if e.metaKey or e.ctrlKey

    # If keycode is a special char (WebKit)
    return if e.which is 0

    # If char is a special char (Firefox)
    return if e.which < 33

    input = String.fromCharCode(e.which)

    # Char is a number
    unless /^\d+$/.test(input)
      e.preventDefault()

  restrictCardNumber:(e) =>
    digit  = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    return if @hasTextSelected(e.target)

    # Restrict number of digits
    value = (e.target.value + digit).replace(/\D/g, '')
    card  = @cardFromNumber(value)

    if card and value.length > card.length[card.length.length - 1]
      e.preventDefault()
    else if value.length > 16
      e.preventDefault()

  restrictExpiry:(e) =>
    digit  = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    return if @hasTextSelected(e.target)

    value = e.target.value + digit
    value = value.replace(/\D/g, '')

    if value.length > 6
      e.preventDefault()

  restrictCVC:(e) =>
    digit  = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)
    return if @hasTextSelected(e.target)
    val = e.target.value + digit
    if val.length > 4
      e.preventDefault()

  # Public

  # Formatting

  cvcInput:(input) ->
    @listen(input, 'keypress', @restrictNumeric)
    @listen(input, 'keypress', @restrictCVC)
    @listen(input, 'paste',    @reFormatCVC)
    @listen(input, 'change',   @reFormatCVC)
    @listen(input, 'input',    @reFormatCVC)

  expiryInput:(input) ->
    @listen(input, 'keypress', @restrictNumeric)
    @listen(input, 'keypress', @restrictExpiry)
    @listen(input, 'keypress', @formatCardExpiry)
    @listen(input, 'keypress', @formatForwardSlashAndSpace)
    @listen(input, 'keypress', @formatForwardExpiry)
    @listen(input, 'keydown',  @formatBackExpiry)
    @listen(input, 'change',   @reFormatExpiry)
    @listen(input, 'input',    @reFormatExpiry)

  cardNumberInput:(input) ->
    @listen(input, 'keypress', @restrictNumeric)
    @listen(input, 'keypress', @restrictCardNumber)
    @listen(input, 'keypress', @formatCardNumber)
    @listen(input, 'keydown',  @formatBackCardNumber)
    @listen(input, 'paste',    @reFormatCardNumber)
    @listen(input, 'change',   @reFormatCardNumber)
    @listen(input, 'input',    @reFormatCardNumber)

  numericInput:(input) ->
    @listen(input, 'keypress', @restrictNumeric)
    @listen(input, 'paste',    @restrictNumeric)
    @listen(input, 'change',   @restrictNumeric)
    @listen(input, 'input',    @restrictNumeric)

  # Validations

  parseCardExpiry:(value) ->
    value = value.replace(/\s/g, '')
    [month, year] = value.split('/', 2)

    # Allow for year shortcut
    if year?.length is 2 and /^\d+$/.test(year)
      prefix = (new Date).getFullYear()
      prefix = prefix.toString()[0..1]
      year   = prefix + year

    month = parseInt(month, 10)
    year  = parseInt(year, 10)

    month: month, year: year

  validateCardNumber:(num) ->
    num = (num + '').replace(/\s+|-/g, '')
    return false unless /^\d+$/.test(num)

    card = cardFromNumber(num)
    return false unless card

    num.length in card.length and
      (card.luhn is false or luhnCheck(num))

  validateCardExpiry:(month, year) ->
    # Allow passing an object
    if typeof month is 'object' and 'month' of month
      {month, year} = month

    return false unless month and year

    month = String(month).trim()
    year  = String(year).trim()

    return false unless /^\d+$/.test(month)
    return false unless /^\d+$/.test(year)
    return false unless 1 <= month <= 12

    if year.length == 2
      if year < 70
        year = "20#{year}"
      else
        year = "19#{year}"

    return false unless year.length == 4

    expiry      = new Date(year, month)
    currentTime = new Date

    # Months start from 0 in JavaScript
    expiry.setMonth(expiry.getMonth() - 1)

    # The cc expires at the end of the month,
    # so we need to make the expiry the first day
    # of the month after
    expiry.setMonth(expiry.getMonth() + 1, 1)

    expiry > currentTime

  validateCardCVC:(cvc, type) ->
    cvc = String(cvc).trim()
    return false unless /^\d+$/.test(cvc)

    card = @cardFromType(type)
    if card?
      # Check against a explicit card type
      cvc.length in card.cvcLength
    else
      # Check against all types
      cvc.length >= 3 and cvc.length <= 4

  parseCardType:(num) ->
    return null unless num
    @cardFromNumber(num)?.type or null

  formatCardNumber:(num) ->
    num  = @replaceFullWidthChars(num)
    num  = num.replace(/\D/g, '')
    card = @cardFromNumber(num)
    return num unless card

    upperLength = card.length[card.length.length - 1]
    num = num[0...upperLength]

    console.log( 'Credit.formatCardNumber()', card.type, card.format.toString(), num )
    if card.format.global
      num.match(card.format)?.join(' ')
    else
      groups = card.format.exec(num)
      return unless groups?
      groups.shift()
      groups = groups.filter(Boolean)
      groups.join(' ')

  formatCardExpiry:(expiry) ->
    expiry = @replaceFullWidthChars(expiry)
    parts = expiry.match(/^\D*(\d{1,2})(\D+)?(\d{1,4})?/)
    return '' unless parts

    mon = parts[1] || ''
    sep = parts[2] || ''
    year = parts[3] || ''

    if year.length > 0
      sep = ' / '

    else if sep is ' /'
      mon = mon.substring(0, 1)
      sep = ''

    else if mon.length == 2 or sep.length > 0
      sep = ' / '

    else if mon.length == 1 and mon not in ['0', '1']
      mon = "0#{mon}"
      sep = ' / '

    return mon + sep + year

