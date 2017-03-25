
$    = require('jquery')
Data = require('js/res/Data')

class StripeRest

  module.exports = StripeRest

  constructor:( @stream, @store, @room, @cust, @res ) ->
    @uri  = "https://api.stripe.com/v1/"
    @subscribe()
    $.ajaxSetup( { headers: { "Authorization": Data.stripeCurlKey } } )

  subscribe:() ->
    @stream.subscribe( 'tokens',  @onToken,  @onError )
    @stream.subscribe( 'charges', @onCharge, @onError )

  ready:() ->
    @token( '4242424242424242', '12', '2018', '123' )

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
    settings.headers = { Authorization: 'Bearer '+ Data.stripeTestKey }
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

  ###
  $.ajax({
    type: 'POST',
    url: 'https://api.stripe.com/v1/charges',
    headers: {
      Authorization: 'Bearer sk_test_YourSecretKeyHere'
    },
    data: {
      amount: 3000,
      currency: 'usd',
      source: response.id,
      description: "Charge for madison.garcia@example.com"
    },
    success: (response) => {
      console.log('successful payment: ', response);
  },
    error: (response) => {
      console.log('error payment: ', response);
   }
   })
  ###