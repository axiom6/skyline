
#$ = require('jquery')

class Credit

  module.exports = Credit
  Credit.Cards   = require( 'data/cards.json' )

  @AmericanExpressFormat = "/(\d{1,4})(\d{1,6})?(\d{1,5})?/"
  @DinersClubFormat      = "/(\d{1,4})(\d{1,6})?(\d{1,4})?/"
  @Unknown =  { type:"Unknown", patterns:[], format:"defaultFormat", length:[16], cvcLength:[], luhn:true }

  constructor:( @selector ) ->

  ready:() ->

  cardFromNumber:(num) ->
    num = (num + '').replace(/\D/g, '')
    for card in Credit.Cards
      for pattern in card.patterns
        p = pattern + ''
        return card if num.substr(0, p.length) == p
    Credit.Unknown

  cardFromType:(type) ->
    return card for card in Credit.Cards when card.type is type

