
class Res

  module.exports = Res

  @init = () ->

    Util.ready ->

      Room   = require( 'js/Room' )
      Cust   = require( 'js/Cust' )
      Book   = require( 'js/Book' )

      room   = new Room()
      cust   = new Cust()
      book   = new Book( room, cust )

      book.ready()

Res.init()