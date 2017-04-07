
$    = require('jquery')

class Pay

  module.exports = Pay

  constructor:( @stream, @store, @room, @cust, @res, @Data ) ->
    @uri  = "https://api.stripe.com/v1/"
    @subscribe()
    $.ajaxSetup( { headers: { "Authorization": @Data.stripeCurlKey } } )
    @myRes = {}
    @created = false

  showConfirmPay:( myRes ) ->
    @myRes = myRes
    if @created
      $('#Confirm').remove()
      $('#Confirm').prepend( @confirmHtml( @myRes ) )
      $('#cc-amt').text('$'+c)
      $('#form-pay').show()
      $('#Pays').show()
    else
      $('#Pays').append( @confirmHtml( @myRes ) )
      $('#Pays').append( @payHtml() )
      $('#Pays').show()
      window.$ = $
      Util.loadScript( "../js/res/payment.js", @initPayment )
      $('#cc-amt').text('$'+myRes.total)
      $('#cc-bak').click( (e) => @onBack(e) )
      @created = true
    return

  onBack:( e ) =>
    e.preventDefault()
    $('#Make').text( 'Change Reservation')
    $('#Pays').hide()
    $('#Book').show()
    return
 
  confirmHtml:( myRes ) ->
    htm   = """<div   id="ConTitle" class= "Title">Confirmation</div>"""
    htm  += """<table id="Confirm"><thead>"""
    htm  += """<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Price</th><th class="arrive">Arrive</th><th class="depart">Depart</th><th>Nights</th><th>Total</th></tr>"""
    htm  += """</thead><tbody>"""
    for own roomId, r of myRes.rooms
      days   = Object.keys(r.days).sort()
      num    = days.length
      arrive = @confirmDate( days[0],     "", false )  # from 3:00-8:00PM
      depart = @confirmDate( days[num-1], "", true  )  # by 10:00AM
      htm  += """<tr><td>#{r.name}</td><td class="guests">#{r.guests}</td><td class="pets">#{r.pets}</td><td class="room-price">$#{r.price}</td><td>#{arrive}</td><td>#{depart}</td><td class="nights">#{num}</td><td class="room-total">$#{r.total}</td></tr>"""
    htm  += """<tr><td></td><td></td><td></td><td></td><td class="arrive-times">Arrival is from 3:00-8:00PM</td><td class="depart-times">Checkout is before 10:00AM</td><td></td><td class="room-total">$#{myRes.total}</td></tr>"""
    htm  += """</tbody></table>"""
    htm  += """<div class="Title">Payment</div>"""
    htm

  departDate:( monthI, dayI, weekdayI ) ->
    dayO     = dayI + 1
    monthO   = monthI
    weekdayO = ( weekdayI + 1 ) % 7
    if dayI >= @Data.numDayMonth[monthI]
       dayO     = 1
       monthO   = monthI + 1
    [monthO, dayO, weekdayO]

  confirmDate:( dayStr, msg, isDepart ) ->
    year       = parseInt( dayStr.substr(0,4) )
    monthIdx   = parseInt( dayStr.substr(4,2) ) - 1
    day        = parseInt( dayStr.substr(6,2) )
    weekdayIdx = new Date( year, monthIdx, day ).getDay()
    [monthIdx,day,weekdayIdx] = @departDate( monthIdx,day,weekdayIdx ) if isDepart
    """#{@Data.weekdays[weekdayIdx]} #{@Data.months[monthIdx]} #{day}, #{year}  #{msg}"""

  payHtml:() ->
    """<form novalidate autocomplete="on" method="POST" id="form-pay">

        <span class="form-group">
          <label for="cc-num" class="control-label">Card Number<span class="text-muted">  [<span class="cc-com"></span>]</span></label>
          <input id= "cc-num" type="tel" class="input-lg form-control cc-num" autocomplete="cc-num" placeholder="•••• •••• •••• ••••" required>
        </span>

        <span class="form-group">
          <label for="cc-exp" class="control-label">Expiration</label>
          <input id= "cc-exp" type="tel" class="input-lg form-control cc-exp" autocomplete="cc-exp" placeholder="mm / yy" required>
        </span>

        <span class="form-group">
          <label for="cc-cvc" class="control-label">CVC</label>
          <input id= "cc-cvc" type="tel" class="input-lg form-control cc-cvc" autocomplete="off" placeholder="•••" required>
        </span>

        <span class="form-group">
          <label for="cc-amt"   class="control-label">Amount</label>
          <div  id= "cc-amt" class="input-lg form-control cc-amt"></div>
        </span>

        <span class="form-group">
          <label class="control-label">&nbsp;</label>
          <button type="submit" class="btn btn-lg btn-primary" id="cc-sub">Pay</button>
        </span>

        <span class="form-group">
          <label class="control-label">&nbsp;</label>
          <button class="btn btn-lg btn-primary" id="cc-bak">Change Reservation</button>
        </span>

        <span class="form-group">
          <label for="cc-msg"   class="control-label">Message</label>
          <div  id= "cc-msg" class="input-lg form-control cc-msg"></div>
        </span>
    </form>"""

  toggleInputError: ( field, valid ) ->
    msg = ''
    if not valid
      msg = switch field
        when 'Num' then 'Invalid Card Number'
        when 'Exp' then 'Invalid Expiration'
        when 'CVC' then 'Invalid CVC'
    msg


  initPayment:() =>
    $('.cc-num').payment('formatCardNumber')
    $('.cc-exp').payment('formatCardExpiry')
    $('.cc-cvc').payment('formatCardCVC'   )
    $('form').submit( (e) => @submitPayment(e) )

  submitPayment:( e ) =>
    e.preventDefault()
    num = $('.cc-num').val()
    exp = $('.cc-exp').val()
    mon =      exp.substr(0,2)
    yer = '20'+exp.substr(5,2)
    cvc = $('.cc-cvc').val()
    cardType = $.payment.cardType(num)

    msg  = @toggleInputError( 'Num', $.payment.validateCardNumber( $('.cc-num').val()) )
    msg += @toggleInputError( 'Exp', $.payment.validateCardExpiry( $('.cc-exp').payment('cardExpiryVal')) )
    msg += @toggleInputError( 'CVC', $.payment.validateCardCVC(    $('.cc-cvc').val(), cardType ) )
    $('.cc-com').text(cardType);
    $('.cc-msg').removeClass('text-danger text-success')
    $('.cc-msg').addClass($('.has-error').length ? 'text-danger' : 'text-success')
    if msg is ''
      $('#cc-sub').text("Waiting For Approval")
      @token( num, mon, yer, cvc )
    else
      $('#cc-sub').text("Input Error")
      $('.cc-msg').text( msg )
    Util.log( 'Pay.submitPayment()', { num:num, exp:exp, cvc:cvc, mon:mon, yer:yer, msg:msg } )
    return

  subscribe:() ->
    @stream.subscribe( 'tokens',  @onToken,  @onError )
    @stream.subscribe( 'charges', @onCharge, @onError )

  token:( number, exp_month, exp_year, cvc ) ->
    input = { "card[number]":number, "card[exp_month]":exp_month, "card[exp_year]":exp_year, "card[cvc]":cvc }
    @ajaxRest( "tokens", 'post', input )
    return

  charge:( token, amount, currency, description ) ->
    input = { source:token, amount:amount, currency:currency, description:description }
    @ajaxRest( "charges", 'post', input )
    return

  onToken:(obj) =>
    Util.log( 'StoreRest.onToken()', obj )
    @tokenId  = obj.id
    @cardId   = obj.card.id
    @charge( @tokenId, @myRes.total, 'usd', 'First Test Charge' )

  onCharge:(obj) =>
    Util.log( 'StoreRest.onCharge()', obj )

  onError:(obj) =>
    Util.error( 'StoreRest.onError()', obj )

  ajaxRest:( table, op, input  ) ->
    url       = @uri + table
    settings  = { url:url, type:op }
    settings.headers = { Authorization: 'Bearer '+ @Data.stripeTestKey }
    settings.data = input
    settings.success = ( result,  status, jqXHR ) =>
      @stream.publish( table, result )
      Util.noop( jqXHR, status )
    settings.error   = ( jqXHR, status, error ) =>
      Util.error( 'StoreRest.ajaxRest()', { status:status, error:error } )
      Util.noop( jqXHR )
    $.ajax( settings )
    return

  toQuery:( input ) ->
    query = ""
    return query if not input?
    for own key, val of input
      query += """@#{key}=#{val}"""
    query[0] = '?'

  toJSON:(     obj  ) -> if obj? then JSON.stringify(obj) else ''

  toObject:(   json ) -> if json then JSON.parse(json) else {}