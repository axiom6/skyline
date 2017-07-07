
$    = require( 'jquery'      )
Data = require( 'js/res/Data' )
UI   = require( 'js/res/UI'   )

class Query

  module.exports =Query

  constructor:( @stream, @store, @res, @master ) ->


  readyQuery:() ->
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvHead() )
    @resvSortClick( 'RHBooked', 'booked' )
    @resvSortClick( 'RHRoom' ,  'roomId' )
    @resvSortClick( 'RHArrive', 'arrive' )
    @resvSortClick( 'RHStayTo', 'stayto' )
    @resvSortClick( 'RHName',   'last'   )
    @resvSortClick( 'RHStatus', 'status' )
    return    

  updateBody:( beg, end, prop ) ->
    $('#QArrive').text( Data.toMMDD(beg) )
    $('#QStayTo').text( Data.toMMDD(end) )
    resvs = {}
    if end?
      resvs = @res.resvArrayByProp( beg, end, prop )
    else
      resvs = @res.resvArrayByDate( beg )
    @resvBody( resvs )

  resvSortClick:( id, prop ) ->
    $('#'+id).click( () => @resvBody( @res.resvArrayByProp( @master.dateBeg, @master.dateEnd, prop ) ) )

  resvHead:() ->
    htm   = "" #"""<div id="QDates"><span id="QArrive"></span><span id="QStayTo"></span></div>"""
    htm  += """<table class="RTTable"><thead><tr>"""
    htm  += """<th id="RHArrive">Arrive</th><th id="RHStayTo">Stay To</th><th id="RHNights">Nights</th><th id="RHRoom"  >Room</th>"""
    htm  += """<th id="RHName"  >Name</th>  <th id="RHGuests">Guests</th> <th id="RHStatus">Status</th><th id="RHBooked">Booked</th>"""
    htm  += """<th id="RHPrice" >Price</th> <th id="RHTotal" >Total</th>  <th id="RHTax"   >Tax</th>   <th id="RHCharge">Charge</th>"""
    htm  += """</tr><tr>"""
    htm  += """<th id="QArrive"></th><th id="QStayTo"></th><th></th><th></th>"""
    htm  += """<th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th>"""
    htm  += """</tr></thead><tbody id="RTBody"></tbody></table>"""
    htm

  resvBody:( resvs ) ->
    $('#RTBody').empty()
    htm = ""
    for r in resvs
      arrive  = Data.toMMDD(r.arrive)
      stayto  = Data.toMMDD(r.stayto)
      booked  = Data.toMMDD(r.booked)
      tax     = Util.toFixed( r.total * Data.tax )
      charge  = Util.toFixed( r.total + parseFloat(tax) )
      trClass = if @res.isNewResv(r) then 'RTNewRow' else 'RTOldRow'
      htm += """<tr class="#{trClass}">"""
      htm += """<td class="RTArrive">#{arrive}  </td><td class="RTStayto">#{stayto}</td><td class="RTNights">#{r.nights}</td>"""
      htm += """<td class="RTRoomId">#{r.roomId}</td><td class="RTLast"  >#{r.last}</td><td class="RTGuests">#{r.guests}</td>"""
      htm += """<td class="RTStatus">#{r.status}</td><td class="RTBooked">#{booked}</td><td class="RTPrice" >$#{r.price}</td>"""
      htm += """<td class="RTTotal" >$#{r.total}</td><td class="RTTax"   >$#{tax}  </td><td class="RTCharge">$#{charge} </td></tr>"""
    $('#RTBody').append( htm )