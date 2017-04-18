
$    = require('jquery')

class Pay

  module.exports = Pay

  constructor:( @stream, @store, @room, @cust, @res, @home, @Data ) ->
    @uri  = "https://api.stripe.com/v1/"
    @subscribe()
    $.ajaxSetup( { headers: { "Authorization": @Data.stripeCurlKey } } )
    @myRes   = {}
    @created = false
    @first   = ''
    @last    = ''
    @phone   = ''
    @email   = ''
    @spas    = false
    @purpose = 'PayInFull' # or 'Deposit'
    @testing = true
    @errored = false

  showSpa:( myRes ) ->
    for own roomId, room of myRes.rooms
      return true if @room.hasSpa(roomId)
    false

  showConfirmPay:( myRes ) =>
    @myRes         = myRes
    @myRes['cust'] = @cust.createCust( @first, @last, @phone, @email, 'site' )
    if @created
      $('#ConfirmTitle').remove()
      $('#ConfirmName' ).remove()
      $('#ConfirmBlock').remove()
      $('.PayBtns'     ).remove()
      $('#MakePay'     ).remove()
      $('#Pays').prepend( @confirmHtml( @myRes ) )
      $('#cc-amt').text('$'+@myRes.total)
      $('#Pays').show()
    else
      $('#Pays').append( @confirmHtml( @myRes ) )
      $('#Pays').append( @payHtml() )
      $('#Pays').show()
      window.$ = $
      Util.loadScript( "../js/res/payment.js", @initCCPayment )  # payment.js need jQuery global
      $('#cc-amt' ).text('$'+@myRes.total)
      $('#ChangeReser').click(  (e) => @onChangeReser( e ) )
      $('#MakeDeposit').click(  (e) => @onMakeDeposit( e ) )
      $('#MakePayment').click(  (e) => @onMakePayment( e ) )
      $('.SpaCheck'   ).change( (e) => @onSpa(         e ) )
      @created = true
    #@testPop() if @testing
    return

  testPop:() ->
    $('#cc-num').val( '4242424242424242' )
    $('#cc-exp').val( '10 / 19'          )
    $('#cc-cvc').val( '555'              )

  onChangeReser:( e ) =>
    e.preventDefault()
    $('#Make').text( 'Change Reservation')
    $('#Pays').hide()
    $('#Book').show()
    return

  onMakeDeposit:( e ) =>
    e.preventDefault()
    @purpose = 'Deposit'
    $("#cc-amt" ).text('$'+@myRes.deposit)
    $('#MakePay').text('Make 50% Deposit')

  onMakePayment:( e ) =>
    e.preventDefault()
    @purpose = 'PayInFull'
    $("#cc-amt" ).text('$'+@myRes.total)
    $('#MakePay').text('Make Payment with Visa Mastercard or Discover')
 
  confirmHtml:( myRes ) ->
    @spas = @showSpa( @myRes )
    canDeposit = @canMakeDeposit( @myRes )
    spaTH = if @spas then "Spa" else ""
    htm   = """<div   id="ConfirmTitle" class= "Title">Confirmation # #{myRes.key}</div>"""
    htm  += """<div   id="ConfirmName">
                  <span>For: #{@first} </span><span>#{@last} </span>
               </div>"""
    htm  += """<div id="ConfirmBlock" class="DivCenter"><table id="ConfirmTable"><thead>"""
    htm  += """<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>#{spaTH}</th><th>Price</th><th class="arrive">Arrive</th><th class="depart">Depart</th><th>Nights</th><th>Total</th></tr>"""
    htm  += """</thead><tbody>"""
    for own roomId, r of myRes.rooms
      days   = Object.keys(r.days).sort()
      num    = days.length
      arrive = @confirmDate( days[0],     "", false )  # from 3:00-8:00PM
      depart = @confirmDate( days[num-1], "", true  )  # by 10:00AM
      htm  += """<tr><td class="td-left">#{r.name}</td><td class="guests">#{r.guests}</td><td class="pets">#{r.pets}</td><td>#{@spa(roomId)}</td><td class="room-price">$#{r.price}</td><td>#{arrive}</td><td>#{depart}</td><td class="nights">#{num}</td><td class="room-total">$#{r.total}</td></tr>"""
    htm  += """<tr><td></td><td></td><td></td><td></td><td></td><td class="arrive-times">Arrival is from 3:00-8:00PM</td><td class="depart-times">Checkout is before 10:00AM</td><td></td><td class="room-total">$#{myRes.total}</td></tr>"""
    htm  += """</tbody></table></div>"""
    htm  += """<div class="PayBtns">"""
    htm  += """  <button class="btn btn-primary" id="ChangeReser">Change Reservation</button>"""
    htm  += """  <button class="btn btn-primary" id="MakeDeposit">Make 50% Deposit</button>""" if canDeposit
    htm  += """  <button class="btn btn-primary" id="MakePayment">Make Payment</button>"""     if canDeposit
    htm  += """</div>"""
    htm  += """<div id="MakePay" class="Title">Make Payment</div>"""
    htm

  canMakeDeposit:( myRes ) ->
    @myRes.arrive >= @Data.advanceDate( @myRes.booked, 7 )

  spa:( roomId ) ->
    Util.log("Util.spa()", roomId, @room.hasSpa(roomId) )
    if @room.hasSpa(roomId) then """<input id="#{roomId}SpaCheck" class="SpaCheck" type="checkbox" value="#{roomId}" checked>""" else ""

  onSpa:( event ) ->
    $elem   = $(event.target)
    roomId  = $elem.attr('id').charAt(0)
    checked = $elem.is(':checked')
    spaFee  = if checked then 20 else -20
    @myRes.rooms[roomId].total += spaFee
    return

  confirmBody:() ->
    body  = """.      Confirmation# #{@myRes.key}\n"""
    body += """.      For: #{@first} #{@last}\n"""
    for own roomId, r of @myRes.rooms
      room   = Util.padEnd( r.name, 24, '-' )
      days   = Object.keys(r.days).sort()
      num    = days.length
      arrive = @confirmDate( days[0],     "", false )  # from 3:00-8:00PM
      depart = @confirmDate( days[num-1], "", true  )  # by 10:00AM
      body  += """#{room} $#{r.price}  #{r.guests}-Guests #{r.pets}-Pets Arrive:#{arrive} Depart:#{depart} #{num}-Nights $#{r.total}\n"""
    body += """\n.      Arrival is from 3:00-8:00PM   Checkout is before 10:00AM\n"""
    body = escape(body)
    body

  confirmEmail:() ->
    win = window.open("""mailto:#{@email}?subject=Skyline Cottages Confirmation&body=#{@confirmBody()}""","EMail")
    win.close() if win? and not win.closed
    return

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
    """
    <div id="PayDiv">
      <form novalidate autocomplete="on" method="POST" id="form-pay">

        <span class="form-group">
          <label for="cc-num" class="control-label">Card Number<span class="text-muted">  [<span class="cc-com">/span>]</span></label>
          <input id= "cc-num" type="tel" class="input-lg form-control cc-num" autocomplete="cc-num" placeholder="•••• •••• •••• ••••" required>
          <div   id= "er-num" class="cc-msg"></div>
        </span>

        <span class="form-group">
          <label for="cc-exp" class="control-label">Expiration</label>
          <input id= "cc-exp" type="tel" class="input-lg form-control cc-exp" autocomplete="cc-exp" placeholder="mm / yy" required>
          <div   id= "er-exp" class="cc-msg"></div>
        </span>

        <span class="form-group">
          <label for="cc-cvc" class="control-label">CVC</label>
          <input id= "cc-cvc" type="tel" class="input-lg form-control cc-cvc" autocomplete="off" placeholder="•••" required>
          <div   id= "er-cvc" class="cc-msg"></div>
        </span>

        <span class="form-group">
          <label for="cc-amt"   class="control-label">Amount</label>
          <div   id= "cc-amt" class="input-lg form-control cc-amt"></div>
          <div   id= "er-amt" class="cc-msg"></div>
        </span>

        <span class="form-group">
          <label  for="cc-sub" class="control-label">&nbsp;</label>
          <button  id="cc-sub" type="submit" class="btn btn-lg btn-primary">Pay</button>
          <div    id= "er-sub" class="cc-msg"></div>
        </span>
      </form>
    </div>
    <div id="Approval"></div>
    """

  toggleInputError: ( field, valid ) ->
    msg = ''
    if not valid
      msg = switch field
        when 'Num' then """Card Number?"""
        when 'Exp' then """Expiration?"""
        when 'CVC' then """CVC?"""
    msg

  initCCPayment:() =>
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
    numerr = @toggleInputError( 'Num', $.payment.validateCardNumber( num ) and @cardAccept(cardType) )
    experr = @toggleInputError( 'Exp', $.payment.validateCardExpiry( $('.cc-exp').payment('cardExpiryVal')) )
    cvcerr = @toggleInputError( 'CVC', $.payment.validateCardCVC(    $('.cc-cvc').val(), cardType ) )
    $('.cc-com').text(cardType);
    $('.cc-msg').removeClass('text-danger text-success')
    $('.cc-msg').addClass($('.has-error').length ? 'text-danger' : 'text-success')
    if numerr is '' and experr is '' and cvcerr is ''
      $('#MakePay' ).hide()
      $('#PayDiv'  ).hide()
      $('.PayBtns' ).hide()
      $('#Approval').text("Waiting For Approval...").show()
      @token( num, mon, yer, cvc )
      @last4 = num.substr( 11, 4 )
    else
      $('#er-num').text(numerr)
      $('#er-exp').text(experr)
      $('#er-cvc').text(cvcerr)
      $('#er-sub').text("Fix?")
      $('#cc-sub').text("Try Again")

    # Util.log( 'Pay.submitPayment()', { num:num, exp:exp, cvc:cvc, mon:mon, yer:yer } )
    return

  cardAccept:( cardType ) ->
    cardType is 'Visa' or cardType is 'Mastercard' or cardType is 'Discover'

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
    @charge( @tokenId, @myRes.total, 'usd', @first + " " + @last )

  onCharge:(obj) =>
    Util.log( 'StoreRest.onCharge()', obj )
    if obj['outcome'].type is 'authorized'
      @confirmEmail()
      $('.PayBtns' ).hide()
      $('#MakePay' ).hide()
      $('#PayDiv'  ).hide()
      $('#Approval').text("Approved: A Confirnation Email Been Sent To #{@email}")
      @home.showConfirm()
      @myRes.payments[@payId()] = @createPayment()
      @store.put( 'Res', @myRes.key, @myRes )
    else
      $('#Approval').text('Denied'  ).show()

  payId:() ->
    pays   = Object.keys(@myRes.payments).sort()
    if pays.length > 0 then toString(parseInt(pays[pays.length-1])+1)  else '1'

  createPayment:() ->
    payment = {}
    payment.amount  = @myRes.total
    payment.date    = @Data.today()
    payment.method  = 'card'
    payment.with    = @last4
    payment.purpose = @purpose
    payment

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

  #pf    = str.replace(/[^-.0-9]/g,'')
  #px    = /^(?:(\d{2})\-)?(\d{3})\-(\d{4})\-(\d{3})$/
  #ph    = '('+@phone.substr(0,3)+')-'+@phone.substr(3,3)+'-'+@phone.substr(6,4)