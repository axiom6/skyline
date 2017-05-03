
$ = require('jquery')

class Test

  module.exports = Test
  Test.Data      = require( 'data/test.json' )

  constructor:( @stream, @store, @Data, @room, @res, @pay, @pict, @book ) ->
    @rooms   = @room.rooms

  doTest:() ->
    for     own resId,  res  of Test.Data
      for   own roomId, room of res
        for own dayId,  day  of res.days
          $cell = $('#R'+roomId+dayId)
          @book.cellBook( $cell )
      cust = res.cust
      @getNamePhoneEmail( cust.first, cust.last, cust.phone, cust.email )
      fn = () => @doGoToPay(res)
      setTimeout( fn, 4000 )
    return

  doGoToPay:( res ) ->
    @book.onGoToPay( null )
    payment = Object.keys(res.payments).sort()[0]
    @popCC( payment.cc, payment.exp, payment.cvc )
    fn = () => @pay.submit( null )
    setTimeout( fn, 4000 )
    return

  getNamesPhoneEmail:( first, last, phone, email ) ->
    [@pay.first,fv] = @pay.isValid('First', first,  true )
    [@pay.last, lv] = @pay.isValid('Last',  last,   true )
    [@pay.phone,pv] = @pay.isValid('Phone', phone,  true )
    [@pay.email,ev] = @pay.isValid('EMail', email,  true )

  popCC:( cc, exp, cvc ) ->
    $('#cc-num').val( cc   )
    $('#cc-exp').val( exp  )
    $('#cc-cvc').val( cvc  )
    return










