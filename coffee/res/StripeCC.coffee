
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
    """<form action="charge.html" method="post" id="payment-form">
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
