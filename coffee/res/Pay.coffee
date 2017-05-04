
$      = require('jquery')
Credit = require( 'js/res/Credit' )

class Pay

  module.exports = Pay

  constructor:( @stream, @store, @Data, @room, @res, @home ) ->
    @credit = new Credit()
    @uri    = "https://api.stripe.com/v1/"
    @subscribe()
    $.ajaxSetup( { headers: { "Authorization": @Data.stripeCurlKey } } )
    @myRes   = {}
    @spas    = false
    @purpose = 'PayInFull' # 'Deposit' 'PayOffDeposit'
    @testing = false
    @errored = false

  showSpa:( myRes ) ->
    for own roomId, room of myRes.rooms
      return true if @room.hasSpa(roomId)
    false

  showConfirmPay:( myRes ) =>
    @myRes         = myRes
    $('#Pays'        ).empty()
    $('#Pays'        ).append( @confirmHead()  )
    $('#ConfirmBlock').append( @confirmTable() )
    $('#Pays'        ).append( @confirmBtns()  )
    $('#PayDiv'      ).append( @payHtml()      )
    $('#Pays'        ).append( @termsHtml()    )
    @initCCPayment()
    @credit.init( 'cc-num', 'cc-exp', 'cc-cvc', 'cc-com' )
    $('#Pays').show()
    @testPop() if @testing
    return

  initCCPayment:() =>
    @hideCCErrors()
    $('#cc-amt' ).text('$'+@myRes.total)
    $('#ChangeReser').click(  (e) => @onChangeReser( e ) )
    $('#MakeDeposit').click(  (e) => @onMakeDeposit( e ) )
    $('#MakePayment').click(  (e) => @onMakePayment( e ) )
    $('.SpaCheck'   ).change( (e) => @onSpa(         e ) )
    $('#cc-sub'     ).click(  (e) => @submitPayment( e ) )
    $('#cc-can'     ).click(  (e) => @onCancel(      e ) )
    return

  hideCCErrors:() ->
    $('#er-num').text('Invalid Number')
    $('#er-num').hide()
    $('#er-exp').hide()
    $('#er-cvc').hide()
    $('#er-sub').hide()
    return

  testPop:() ->
    $('#cc-num').val( '4242424242424242' )
    $('#cc-exp').val( '10/19'            )
    $('#cc-cvc').val( '555'              )
    return

  onChangeReser:( e ) =>
    e.preventDefault()
    $('#Make').text( 'Change Reservation')
    $('#Pays').hide()
    $('#Book').show()
    return

  onCancel:( e ) =>
    e.preventDefault()
    @home.onHome()
    return

  calcDeposit:() ->
    Math.round( @myRes.total * 50 ) / 100

  onMakeDeposit:( e ) =>
    e.preventDefault()
    @purpose = 'Deposit'
    $("#cc-amt" ).text('$'+@calcDeposit() )
    $('#MakePay').text('Make 50% Deposit')

  onMakePayment:( e ) =>
    e.preventDefault()
    @purpose = 'PayInFull'
    $("#cc-amt" ).text('$'+@myRes.total)
    $('#MakePay').text('Make Payment with Visa Mastercard or Discover')

  ccAmt:() ->
    amt = if @purpose is 'Deposit' then @calcDeposit() else @myRes.total
    $("#cc-amt" ).text('$'+amt)
    return

  confirmHead:() ->
    htm   = """<div id="ConfirmTitle" class= "Title">Confirmation # #{@myRes.key}</div>"""
    htm  += """<div><div id="ConfirmName"><span>For: #{@myRes.cust.first} </span><span>#{@myRes.cust.last} </span></div></div>"""
    htm  += """<div id="ConfirmBlock" class="DivCenter"></div>"""
    htm
 
  confirmTable:() ->
    @spas = @showSpa( @myRes )
    spaTH = if @spas then "Spa" else ""
    htm   = """<table id="ConfirmTable"><thead>"""
    htm  += """<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>#{spaTH}</th><th>Price</th><th class="arrive">Arrive</th><th class="depart">Depart</th><th>Nights</th><th>Total</th></tr>"""
    htm  += """</thead><tbody>"""

    for own roomId, r of @myRes.rooms
      days   = Object.keys(r.days).sort()
      num    = days.length
      bday   = days[0]
      i      = 0
      total  = 0
      night  = 0
      while i < num
        eday   = days[i]
        total += r.price
        night++
        if i is num-1 or days[i+1] isnt @Data.advanceDate( eday, 1 )
          arrive = @confirmDate( bday, "", false )
          depart = @confirmDate( eday, "", true  )
          htm  += """<tr><td class="td-left">#{r.name}</td><td class="guests">#{r.guests}</td><td class="pets">#{r.pets}</td><td>#{@spa(roomId)}</td><td class="room-price">$#{r.price}</td><td>#{arrive}</td><td>#{depart}</td><td class="nights">#{night}</td><td id="#{roomId}TR" class="room-total">$#{total}</td></tr>"""
          bday  = days[i+1]
          total = 0
          night = 0
        i++

    htm  += """<tr><td></td><td></td><td></td><td></td><td></td><td class="arrive-times">Arrival is from 3:00-8:00PM</td><td class="depart-times">Checkout is before 10:00AM</td><td></td><td  id="TT" class="room-total">$#{@myRes.total}</td></tr>"""
    htm  += """</tbody></table>"""
    htm

  confirmBtns:() ->
    canDeposit = @canMakeDeposit( @myRes )
    htm   = """<div class="PayBtns">"""
    htm  += """  <button class="btn btn-primary" id="ChangeReser">Change Reservation</button>"""
    htm  += """  <button class="btn btn-primary" id="MakeDeposit">Make 50% Deposit</button>""" if canDeposit
    htm  += """  <button class="btn btn-primary" id="MakePayment">Make Payment</button>"""     if canDeposit
    htm  += """</div>"""
    htm  += """<div id="MakePay" class="Title">Make Payment</div>"""
    htm  += """<div id="PayDiv"></div>"""
    htm  += """<div id="Approval"></div>"""
    htm

  canMakeDeposit:( myRes ) ->
    @myRes.arrive >= @Data.advanceDate( @myRes.booked, 7 )

  spa:( roomId ) ->
    #Util.log("Util.spa()", roomId, @room.hasSpa(roomId) )
    if @room.hasSpa(roomId) then """<input id="#{roomId}SpaCheck" class="SpaCheck" type="checkbox" value="#{roomId}" checked>""" else ""

  onSpa:( event ) ->
    $elem   = $(event.target)
    roomId  = $elem.attr('id').charAt(0)
    checked = $elem.is(':checked')
    spaFee  = if checked then 20 else -20
    @myRes.rooms[roomId].total += spaFee
    @myRes.total               += spaFee
    $('#'+roomId+'TR').text('$'+@myRes.rooms[roomId].total)
    $('#TT'          ).text('$'+@myRes.total)
    @ccAmt()
    return

  confirmBody:() ->
    body  = """.      Confirmation# #{@myRes.key}\n"""
    body += """.      For: #{@myRes.cust.first} #{@myRes.cust.last}\n"""
    for own roomId, r of @myRes.rooms
      room   = Util.padEnd( r.name, 24, '-' )
      days   = Object.keys(r.days).sort()
      num    = days.length
      bday   = days[0]
      i      = 1
      total  = r.price
      while i < num
        eday = days[i]
        if i is num-1 or eday isnt @Data.advance( eday, 1 )
          arrive = @confirmDate( bday,        "", false )
          depart = @confirmDate( days[num-1], "", true  )
          body  += """#{room} $#{r.price}  #{r.guests}-Guests #{r.pets}-Pets Arrive:#{arrive} Depart:#{depart} #{num}-Nights $#{total}\n"""
        i++
    body += """\n.      Arrival is from 3:00-8:00PM   Checkout is before 10:00AM\n"""
    body = escape(body)
    body

  confirmEmail:() ->
    win = window.open("""mailto:#{@myRes.cust.email}?subject=Skyline Cottages Confirmation&body=#{@confirmBody()}""","EMail")
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
    numPtn="\d{4} \d{4} \d{4} \d{4}"
    expPtn="(1[0-2]|0[1-9])\/\d\d"
    cvcPtn="\d{3}"
    """
    <div id="form-pay">
      <span class="form-group">
        <label for="cc-num" class="control-label" id="cc-com">Card Number</label>
        <input id= "cc-num" type="tel" class="input-lg form-control cc-num masked" placeholder="•••• •••• •••• ••••" pattern="#{numPtn}" required>
        <div   id= "er-num" class="cc-msg">Invalid Number</div>
      </span>

      <span class="form-group">
        <label for="cc-exp" class="control-label">MM/YY Expiration</label>
        <input id= "cc-exp" type="tel" class="input-lg form-control cc-exp masked" placeholder="MM/YY" pattern="#{expPtn}" required>
        <div   id= "er-exp" class="cc-msg">Invalid MM/YY</div>
      </span>

      <span class="form-group">
        <label for="cc-cvc" class="control-label">CVC</label>
        <input id= "cc-cvc" type="tel" class="input-lg form-control cc-cvc masked" placeholder="•••" pattern="#{cvcPtn}"  required>
        <div   id= "er-cvc" class="cc-msg">Invalid CVC</div>
      </span>

      <span class="form-group">
        <label for="cc-amt"   class="control-label">Amount</label>
        <div   id= "cc-amt" class="input-lg form-control cc-amt"></div>
        <div   id= "er-amt" class="cc-msg"></div>
      </span>

      <span class="form-group">
        <label  for="cc-sub" class="control-label">&nbsp;</label>
        <button id= "cc-sub" class="btn btn-lg btn-primary">Pay</button>
        <div    id= "er-sub" class="cc-msg"></div>
      </span>

      <span class="form-group">
        <label  for="cc-can" class="control-label">&nbsp;</label>
        <button id= "cc-can" class="btn btn-lg btn-primary">Cancel</button>
        <div    id= "er-can" class="cc-msg"></div>
      </span>
    </div>
    """

  submitPayment:( e ) =>
    e.preventDefault() if e?
    @hideCCErrors()

    num = $('#cc-num').val()
    exp = $('#cc-exp').val()
    cvc = $('#cc-cvc').val()

    card   = @credit.cardFromNumber(  num )
    iry    = @credit.parseCardExpiry( exp )
    accept = @cardAccept(card.type)

    ne = @credit.validateCardNumber( num )
    ee = @credit.validateCardExpiry( iry )
    ce = @credit.validateCardCVC(    cvc, card.type )

    mon =      exp.substr(0,2)
    yer = '20'+exp.substr(5,2)
    if ne and ee and ce and accept
      @hidePay()
      $('#Approval').text("Waiting For Approval...").show()
      @token( num, mon, yer, cvc )
      @last4 = num.substr( 11, 4 )
    else
      ae = card.type + ' not accepted'
      $('#er-num').text(ae) if not accept
      $('#er-num').show()   if not ne or not accept
      $('#er-exp').show()   if not ee
      $('#er-cvc').show()   if not ce

    #Util.log( 'Pay.submitPayment()', { num:num, ne:ne, exp:exp, ee:ee, cvc:cvc, ce:ce, mon:mon, yer:yer } )
    return

  hidePay:() ->
    $('#MakePay' ).hide()
    $('#PayDiv'  ).hide()
    $('.PayBtns' ).hide()

  showPay:() ->
    $('#MakePay' ).show()
    $('#PayDiv'  ).show()
    $('.PayBtns' ).show()

  isValid:( name, test, testing=false ) ->
    value = $('#'+name).val()
    valid = Util.isStr( value )
    if testing
      $('#'+name).val(test)
      value = test
      valid = true
    #$('#'+name+'ER').show() if not valid
    [value,valid]

  cardAccept:( cardType ) ->
    cardType is 'Visa' or cardType is 'Mastercard' or cardType is 'Discover'

  subscribe:() ->
    @stream.subscribe( 'tokens',  @onToken,  @onError )
    @stream.subscribe( 'charges', @onCharge, @onError )

  token:( number, exp_month, exp_year, cvc ) ->
    input = { "card[number]":number, "card[exp_month]":exp_month, "card[exp_year]":exp_year, "card[cvc]":cvc }
    @ajaxRest( "tokens", 'post', input, @onTokenError )
    return

  charge:( token, amount, currency, description ) ->
    input = { source:token, amount:amount, currency:currency, description:description }
    @ajaxRest( "charges", 'post', input, @onChargeError )
    return

  onTokenError:( error, status ) =>
    Util.noop(   error, status )
    @showPay()
    $('#Approval').text("Unable to Verify Card").show()
    return

  onChargeError:( error, status ) =>
    Util.noop(    error, status )
    @showPay()
    $('#Approval').text("Payment Denied").show()
    return

  onToken:(obj) =>
    #Util.log( 'StoreRest.onToken()', obj )
    @tokenId  = obj.id
    @cardId   = obj.card.id
    @charge( @tokenId, @myRes.total, 'usd', @myRes.cust.first + " " + @myRes.cust.last )

  onCharge:(obj) =>
    #Util.log( 'StoreRest.onCharge()', obj )
    if obj['outcome'].type is 'authorized'
      @doConfirm()
      @postRes()
    else
      @doDeny()
      #@denyRes()

  doConfirm:() ->
    @confirmEmail()
    @hidePay()
    $('#Approval').text("Approved: A Confirnation Email Been Sent To #{@myRes.cust.email}")
    @home.showConfirm()

  doDeny:() ->
    @showPay()
    $('#Approval').text('Payment Denied').show()

  postRes:() =>
    @setResStatus( 'post' )
    payId = @Data.genPaymentId(  @myRes.resId, @myRes.payments )
    @myRes.payments[payId] = @createPayment()
    @res.postRes( @myRes.resId, @myRes )

  # Not sure what we want to do here
  denyRes:() =>
    @setResStatus( 'deny' )
    payId = @Data.genPaymentId( @myRes.resId, @myRes.payments )
    @myRes.payments[payId] = @createPayment()
    @res.postRes( @myRes.resId, @myRes )

  setResStatus:( state ) ->
    if       state is 'post'
      @myRes.status = 'book' if @purpose is 'PayInFull' or @purpose is 'PayOffDeposit'
      @myRes.status = 'depo' if @purpose is 'Deposit'
    else if  state is 'deny'
      @myRes.status = 'free'

    if not Util.inArray(['book','depo','free'], @myRes.status )
      Util.error( 'Pay.setResStatus() unknown status ', @myRes.status )
      @myRes.status = 'free'
    return

  createPayment:() ->
    payment = {}
    payment.amount  = @myRes.total
    payment.date    = @Data.today()
    payment.method  = 'card'
    payment.with    = @last4
    payment.purpose = @purpose
    payment.cc      = ''
    payment.exp     = ''
    payment.cvc     = ''
    payment

  onError:(obj) =>
    Util.error( 'StoreRest.onError()', obj )

  ajaxRest:( table, op, input, onError ) ->
    url       = @uri + table
    settings  = { url:url, type:op }
    settings.headers = { Authorization: 'Bearer '+ @Data.stripeTestKey }
    settings.data = input
    settings.success = ( result,  status, jqXHR ) =>
      @stream.publish( table, result )
      Util.noop( jqXHR, status )
      return
    settings.error   = ( jqXHR, status, error ) =>
      Util.noop( jqXHR )
      onError( status, error )
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

  termsHtml:() ->
    """
      <ul class="Terms">
        <li>Prices have been automatically calculated.</li>
        <li>The number of guests and pets has to be declared in the reservation.</li>
        <li>Pricing for 1-2 guests is the same for cottages 1 2 4 7 8 N S.</li>
        <li>Pricing for 1-4 guests is the same for cottages 3 5 6.</li>
        <li>Additional guests are $10 per night.</li>
        <li>Each pet is $12 per night.</li>
        <li>Deposit is 50% of total reservation.</li>
        <li>There will be a deposit refund with a 50-day cancellation notice, less a $50 fee.</li>
        <li>Less than 50-day notice, deposit is forfeited.</li>
        <li>Short term reservations have a 3-day cancellation deadline.</li>
      </ul>
    """
