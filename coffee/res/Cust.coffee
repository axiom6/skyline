
class Cust

  module.exports = Cust
  Cust.Data      = require( 'data/Cust.json' )

  constructor:( @stream, @store ) ->

  createCust:( first, last, phone, email, source ) ->
    cust = {}
    cust.id     = @Data.genCustId( phone )
    cust.first  = first
    cust.last   = last
    cust.phone  = phone
    cust.email  = email
    cust.source = source
    @add( cust.id, cust )
    cust

  add:( id, cust ) -> @store.add( 'Cust', id, cust )
  get:( id       ) -> @store.get( 'Cust', id       )
  put:( id, cust ) -> @store.put( 'Cust', id, cust )
  del:( id       ) -> @store.del( 'Cust', id       )
