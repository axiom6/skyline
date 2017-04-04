
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
      $('#Confirms').remove()
      $('#Confirm').prepend( @confirmHtml( @myRes ) )
      $('#form-pay').show()
    else
      $('#Confirm').append( @confirmHtml( @myRes ) )
      $('#Confirm').append( @payHtml() )
      window.$ = $
      Util.loadScript( "../js/res/payment.js", @initPayment )
      $('#cc-amt').text('$'+myRes.total)
      $('#cc-bak').click( (e) => @onBack(e) )
      # @token( '4242424242424242', '12', '2018', '123' )
      @created = true

  onBack:( e ) =>
    e.preventDefault()
    $('#Confirms').hide()
    $('#form-pay').hide()
    $('#Inits'   ).show()
    $('#Rooms'   ).show()
    $('#MakeRes' ).show()
    return
 
  confirmHtml:( myRes ) ->
    htm   = """<table id="Confirms"><thead>"""
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
    #tm  += """<div>Arrivals are from 3:00-8:00PM  Departures are before 10:00AM</div>"""
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
          <button class="btn btn-lg btn-primary" id="cc-bak">Go Back</button>
        </span>

        <span class="form-group">
          <label for="cc-msg"   class="control-label">Message</label>
          <div  id= "cc-msg" class="input-lg form-control cc-msg"></div>
        </span>
    </form>"""

  toggleInputError: ( field, status ) ->
    text = switch field
      when 'Num' then 'Invalid Card Number'
      when 'Exp' then 'Invalid Expiration'
      when 'CVC' then 'Invalid CVC'
      else            ''
    $("#cc-msg").text( text )  if status
    this

  initPayment:() =>
    $('.cc-num').payment('formatCardNumber')
    $('.cc-exp').payment('formatCardExpiry')
    $('.cc-cvc').payment('formatCardCVC'   )
    $('form').submit( (e) => @submitPayment(e) )

  submitPayment:( e ) =>
    e.preventDefault()
    cardType = $.payment.cardType($('.cc-num').val())
    @toggleInputError( 'Num', !$.payment.validateCardNumber( $('.cc-num').val()) )
    @toggleInputError( 'Exp', !$.payment.validateCardExpiry( $('.cc-exp').payment('cardExpiryVal')) )
    @toggleInputError( 'CVC', !$.payment.validateCardCVC(    $('.cc-cvc').val(), cardType ) )
    $('.cc-com').text(cardType);
    $('.cc-msg').removeClass('text-danger text-success')
    $('.cc-msg').addClass($('.has-error').length ? 'text-danger' : 'text-success')
    $('#cc-sub').text("Approved")
    return

  subscribe:() ->
    @stream.subscribe( 'tokens',  @onToken,  @onError )
    @stream.subscribe( 'charges', @onCharge, @onError )

  token:( number, exp_month, exp_year, cvc ) ->
    input = { "card[number]":number, "card[exp_month]":exp_month, "card[exp_year]":exp_year, "card[cvc]":cvc }
    @ajaxRest( "tokens", 'post', input )

  charge:( token, amount, currency, description ) ->
    input = { source:token, amount:amount, currency:currency, description:description }
    @ajaxRest( "charges", 'post', input )

  onToken:(obj) =>
    Util.log( 'StoreRest.onToken()', obj )
    @token  = obj.id
    @cardId = obj.card.id
    @charge( @token, 800, 'usd', 'First Test Charge' )

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