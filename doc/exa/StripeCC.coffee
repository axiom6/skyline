
$       = require('jquery')
Data    = require('js/res/Data')
#stripe = require("stripe")(Data.stripeTestKey) # Using browser

class StripeCC

  module.exports = StripeCC

  constructor:( @stream, @store, @room, @cust, @res ) ->
    @stripe   = Stripe( Data.stripeTestPub )
    @elements = @stripe.elements()

  ready:() ->
    $("#StripeCC").append( @elementsForm() )
    @card = @elements.create('card', { style:@elementsStyle() } )
    @card.mount('#card-element')
    @form = document.getElementById('payment-form')
    @card.addEventListener( 'change', (event) => @onCardError(  event ) )
    @form.addEventListener( 'submit', (event) => @onFormSubmit( event ) )
    return

  elementsForm:() ->
    """<form action="/charge" method="post" id="payment-form">
        <div class="form-row">
          <label for="card-element">Credit or debit card</label>
          <div id="card-element"></div>
          <div id="card-errors"></div>
        </div>
        <button>Submit Payment</button>
      </form>"""

  elementsStyle:() ->
    { base: { fontSize:'16px', lineHeight:'24px' } }

  onCardError:( event ) =>
    displayError = document.getElementById('card-errors')
    if event.error
      displayError.textContent = event.error.message
    else
      displayError.textContent = ''
    return

  onFormSubmit:( event ) =>
    event.preventDefault()
    @stripe.createToken(@card).then( (result) =>
      if result.error
        errorElement = document.getElementById('card-errors') # Inform the user if there was an error
        errorElement.textContent = result.error.message
      else
        @stripeTokenHandler( result.token ) ) # Send the token to your server

  stripeTokenHandler:( token ) =>
    # Insert the token ID into the form so it gets submitted to the server
    hiddenInput = document.createElement('input')
    hiddenInput.setAttribute('type', 'hidden' )
    hiddenInput.setAttribute('name', 'stripeToken' )
    hiddenInput.setAttribute('value', token.id )
    @form.appendChild( hiddenInput )
    @form.submit()

  createToken:( ) ->
    @stripe.card.createToken( {
      number: $('.card-number').val(), cvc: $('.card-cvc').val(),
      exp_month: $('.card-expiry-month').val(), exp_year: $('.card-expiry-year').val() }, @stripeResponseHandler )

  stripeResponseHandler:( status, response ) =>
    $form = $('#payment-form') # Grab the form:
    if response.error
      $form.find('.payment-errors').text(response.error.message)  # Show the errors on the form
      $form.find('button').prop('disabled', false )               # Re-enable submission
    else # Token was created!
      token = response.id # Get the token ID:
      # Insert the token into the form so it gets submitted to the server:
      $form.append( $("""<input type="hidden" name="stripeToken" />""").val(token) )
      $form.get(0).submit() # Submit the form:
    return

  responseObj:() ->
    {
      id: "tok_8DPg4qjJ20F1aM", # Token identifier
      card: { # Dictionary of the card used to create the token
        name: null,
        address_line1: "12 Main Street",
        address_line2: "Apt 42",
        address_city: "Palo Alto",
        address_state: "CA",
        address_zip: "94301",
        address_country: "US",
        country: "US",
        exp_month: 2,
        exp_year: 2018,
        last4: "4242",
        object: "card",
        brand: "Visa",
        funding: "credit"
      },
      created: 1490292526, # Timestamp of when token was created
      livemode: true,      # Whether this token was created with a live API key
      type: "card",
      object: "token",     # Type of object, always "token"
      used: false          # Whether this token has been used
    }