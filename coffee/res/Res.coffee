
class Res

  module.exports = Res

  @init = () ->

    Util.ready ->

      Room   = require( 'js/res/Room' )
      Cust   = require( 'js/res/Cust' )
      Book   = require( 'js/res/Book' )
      Store  = require( 'js/store/Store')

      room   = new Room()
      cust   = new Cust()
      book   = new Book( room, cust )

      book.ready()

Res.init()