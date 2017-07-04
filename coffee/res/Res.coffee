
$ = require( 'jquery' )

class Res

  module.exports = Res
  Res.Rooms = require( 'data/room.json' )
  Res.Sets  = ['full','book','resv','chan']  # Data set for @res.days and @res.resv

  constructor:( @stream, @store, @Data, @appName ) ->
    @rooms     = Res.Rooms
    @roomKeys  = Util.keys( @rooms )
    @book      = null
    @master    = null
    @days      = {}
    @resvs     = {}
    @order     = 'Decend'
    @today     = @Data.today()
    @onCompleteResv = null
    @dateRange( @Data.beg, @Data.end ) if @appName is 'Guest' # Get entire season for both Guest and Owner

  dateRange:( beg, end, onComplete=null ) ->
    @store.subscribe( 'Day', 'range', 'none', (days) =>
      @days = days
      day.status = @Data.toStatus(day.status) for own dayId, day of @days
      onComplete() if onComplete? )
    @store.range( 'Day', beg+'1', end+'S' )
    return

  selectAllDays:( onComplete=null ) ->
    @store.subscribe( 'Day', 'select', 'none', (days) =>
      @days = days
      day.status = @Data.toStatus(day.status) for own dayId, day of @days
      onComplete() if onComplete? )
    @store.select( 'Day' )
    return

  selectAllResvs:( onComplete=null ) =>
    @store.subscribe( 'Res', 'select', 'none', (resvs) =>
      @resvs = resvs
      resv.status = @Data.toStatus(resv.status) for own resId, resv of @resvs
      onComplete() if onComplete? ) # resvs not passed to onComplete() - accesss @resvs later on
    @store.select( 'Res' )
    return

  selectAllDaysResvs:( onComplete=null ) =>
    @selectAllDays(  () => @selectAllResvs(onComplete) )
    return

  # Note the expanded roomUI is for Book.coffee and should never be persisted
  roomUI:( rooms ) ->
    for own key, room of rooms
      room.$ = {}
      room   = @populateRoom( room, {}, 0, 0, 2, 0 )
    return

  populateRoom:( room, days, total, price, guests, pets ) ->
    room.days    = days
    room.total   = total
    room.price   = price
    room.guests  = guests
    room.pets    = pets
    room.change  = 0         # Changes usually to spa opt out
    room.reason  = 'No Changes'
    room

  isNewResv:( resv ) ->
    nights = @Data.nights( resv.booked, @today )
    nights < @Data.newDays

  # This is a hack for unreliable storage in jQuery.attr - found other formating error so not needed
  attr:( $elem, name ) ->
    value = $elem.attr( name.toLowerCase() )
    Util.log( 'Res.attr one', name, value )
    value = if Util.isStr(value) and value.charAt(0) is ' ' then value.substr(1)     else value
    value = if Util.isStr(value) then Util.toCap(value) else value
    Util.log( 'Res.attr two', name, value )
    value

  status:( date, roomId ) ->
    dayId = @Data.dayId( date, roomId )
    day   = @days[dayId]
    if day? then day.status else 'Free'

  klass:( date, roomId ) ->
    resv   = @getResv( date, roomId )
    status = 'Free'
    if resv?
       status = resv.status
       if @isNewResv( resv )
         status = 'SkylNew' if status is 'Skyline' or status is 'book'
         status = 'BookNew' if status is 'Booking' or status is 'chan'
    else
       status = @status( date, roomId )
    #Util.log( 'Res.color()', date, roomId, resv?, nights, status )
    status

  getResv:( date, roomId ) ->
    day   = @day( date, roomId )
    if day? then @resvs[day.resId] else null

  day:( date, roomId ) ->
    dayId = @Data.dayId( date, roomId )
    day   = @days[dayId]
    if day? then day else @setDay( {}, 'Free', 'none' )

  dayIds:( arrive, stayto, roomId ) ->
    depart = Data.advanceDate( stayto, 1 )
    nights = @Data.nights( arrive, depart )
    ids = []
    for i in [0...nights]
      ids.push( @Data.dayId( @Data.advanceDate( arrive, i ), roomId ) )
    ids

  allocDays:( days ) ->
    @book.  allocDays( days ) if @book?
    @master.allocDays( days ) if @master?
    return

  updateResvs:( newResvs ) ->
    for own resId, resv of newResvs
      @addResv( resv )
    @resvs

  updateDaysFromResv:( resv ) ->
    #Util.log( 'Res', resv )
    days = {} # resv days
    for i in [0...resv.nights]
      dayId       = @Data.dayId( @Data.advanceDate( resv.arrive, i ), resv.roomId )
      days[dayId] = @setDay( {}, resv.status, resv.resId )
    @allocDays( days )
    for dayId, day of days
      #Util.log( 'Day',   dayId, day )
      if resv.status is 'Free'
        @store.del( 'Day', dayId )
        delete @days[dayId]
      else
        @store.add( 'Day', dayId, day )
        @days[dayId] = day
    return

  calcPrice:( roomId, guests, pets ) ->
    #Util.log( 'Res.calcPrice()', { roomId:roomId, guests:guests, pets:pets, guestprice:@rooms[roomId][guests], petfee:pets*@Data.petPrice  } )
    @rooms[roomId][guests] + pets*@Data.petPrice

  spaOptOut:( roomId, isSpaOptOut=true ) ->
    if @rooms[roomId].spa is 'O' and isSpaOptOut then Data.spaOptOut else 0

  genDates:( arrive, nights ) ->
    dates = {}
    for i in [0...nights]
      date = @Data.advanceDate( arrive, i )
      dates[date] = ""
    dates

  # .... Creation ........

  createResvSkyline:( arrive, depart, roomId, last, status, guests, pets, spa=false, cust={}, payments={} ) ->
    booked = @Data.today()
    price  = @rooms[roomId][guests] + pets*@Data.petPrice
    nights = @Data.nights( arrive, depart )
    total  = price * nights
    @createResv( arrive, depart, booked, roomId, last, status, guests, pets, 'Skyline', total, spa, cust, payments )

  createResvBooking:( arrive, depart, roomId, last, status, guests, total, booked ) ->
    total  = if total is 0 then @rooms[roomId].booking * @Data.nights( arrive, depart ) else total
    pets   = 0
    @createResv( arrive, depart, booked, roomId, last, status, guests, pets, 'Booking', total )

  createResv:( arrive, depart, booked, roomId, last, status, guests, pets, source, total, spa=false, cust={}, payments={} ) ->
    resv           = {}
    resv.nights    = @Data.nights( arrive, depart )
    resv.arrive    = arrive
    resv.depart    = depart
    resv.booked    = booked
    resv.stayto    = @Data.advanceDate( arrive, resv.nights - 1 )
    resv.roomId    = roomId
    resv.last      = last
    resv.status    = status
    resv.guests    = guests
    resv.pets      = pets
    resv.source    = source
    resv.resId     = @Data.resId( arrive, roomId )
    resv.total     = total
    resv.price     = total / resv.nights
    resv.tax       = Util.toFixed( total * @Data.tax )
    resv.spaOptOut = @spaOptOut( roomId, spa )
    resv.charge    = Util.toFixed( total + parseFloat(resv.tax) - resv.spaOptOut )
    resv.paid      = 0
    resv.balance   = 0
    resv.cust      = cust
    resv.payments  = payments
    @updateDaysFromResv( resv )
    resv

  createCust:( first, last, phone, email, source ) ->
    cust = {}
    cust.custId = @Data.genCustId( phone )
    cust.first  = first
    cust.last   = last
    cust.phone  = phone
    cust.email  = email
    cust.source = source
    cust

  createPayment:( amount, method, last4, purpose ) ->
    payment = {}
    payment.amount  = amount
    payment.date    = @Data.today()
    payment.method  = method
    payment.with    = method
    payment.last4   = last4
    payment.purpose = purpose
    payment.cc      = ''
    payment.exp     = ''
    payment.cvc     = ''
    payment

  # .... Persistence ........

  onRes:( op, doRes  ) => @store.on( 'Res', op, 'none', (resId,res) => doRes(resId,res) )
  onDay:( op, doDay  ) => @store.on( 'Day', op, 'none', (dayId,day) => doDay(dayId,day) )

  # We don't always know or want to listen to a single resId
  #onResId:( op, doResv, resId ) => @store.on( 'Res', op,  resId, (resId,resv) => doResv(resId,resv) )

  insert:( table, rows, onComplete=null ) =>
    @store.subscribe( table, 'insert', 'none', (rows) => onComplete(rows) if onComplete? )
    @store.insert(    table,  rows )
    return

  select:( table, rows, onComplete=null ) =>
    @store.subscribe( table, 'select', 'none', (rows) => onComplete(rows) if onComplete? )
    @store.select(    table )
    return

  make:( table, rows, onComplete=null ) ->
    @store.subscribe( table, 'make', 'none', ()  => @insert( table, rows, onComplete() if onComplete? ) )
    @store.make( table )

  makeTables:() ->
    @make( 'Room', Res.Rooms )
    @store.make( 'Res' )
    @store.make( 'Day' )

  setResvStatus:( resv, post, purpose ) ->
    if        post is 'post'
        resv.status = 'Skyline' if purpose is 'PayInFull' or purpose is 'Complete'
        resv.status = 'Deposit' if purpose is 'Deposit'
    else if   post is 'deny'
        resv.status = 'Free'
    if not Util.inArray(@Data.statuses, resv.status )
      Util.error( 'Pay.setResStatus() unknown status ', resv.status )
      resv.status = 'Free'
    resv.status

  addResv:( resv ) ->
    @resvs[resv.resId] = resv
    @store.add( 'Res', resv.resId, resv )

  putResv:( resv ) ->
    @resvs[resv.resId] = resv
    @store.put( 'Res', resv.resId, resv )

  canResv:( resv ) ->                     #Cancel
    @resvs[resv.resId] = resv
    @store.put( 'Res', resv.resId, resv ) # We do a put

  delResv:( resv ) ->                     #Delete
    delete @resvs[resv.resId]
    @store.del( 'Res', resv.resId )

  postPayment:( resv, post, amount, method, last4, purpose ) ->
    status = @setResvStatus( resv, post, purpose )
    if status is 'Skyline' or status is 'Deposit'
      payId = @Data.genPaymentId( resv.resId, resv.payments )
      resv.payments[payId] = @createPayment( amount, method, last4, purpose )
      resv.paid   += amount
      resv.balance = resv.totals - resv.paid
      @postResv( resv )
    return

  # Used for Days / dayId / roomId and for Res / rooms[dayId] since both has status and resid properties
  setDay:( day, status, resId ) ->
    day.status = status
    day.resId  = resId
    day

  # ......Utilities ......

  optSpa:( roomId ) -> @rooms[roomId].spa is 'O'
  hasSpa:( roomId ) -> @rooms[roomId].spa is 'O' or @rooms[roomId].spa is 'Y'

  # ...... UI Elements that does not quite belong here .....

  htmlSelect:( htmlId, array, choice, klass="", max=undefined ) ->
    style = if Util.isStr(klass) then klass else htmlId
    htm   = """<select name="#{htmlId}" id="#{htmlId}" class="#{style}">"""
    where = if max? then (elem) -> elem <= max else () -> true
    for elem in array when where(elem)
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  # UI Element that does that quite belong here
  htmlInput:( htmlId, value="", klass="", label="", type="text" ) ->
    style = if Util.isStr(klass) then klass else htmlId
    htm   = ""
    htm  += """<label for="#{htmlId}" class="#{style+'Label'}">#{label}</label>"""  if Util.isStr(label)
    htm  += """<input id= "#{htmlId}" class="#{style}" value="#{value}" type="#{type}">"""
    htm

  htmlButton:( htmlId, klass, title ) ->
    """<button id="#{htmlId}" class="btn btn-primary #{klass}">#{title}</button>"""

  # Sets htmlId property on obj
  makeSelect:( htmlId, obj ) =>
    onSelect = (event) =>
      obj[htmlId] = event.target.value
      Util.log( htmlId, obj[htmlId] )
    $('#'+htmlId).change( onSelect )
    return

  # Sets htmlId property on obj
  makeInput:( htmlId, obj ) =>
    onInput = (event) =>
      obj[htmlId] = event.target.value # $('#'+htmlId).val()
      Util.log( htmlId, obj[htmlId] )
    $('#'+htmlId).change( onInput )
    return
    
  # Query

  resvArrayByDate:( date ) ->
    array  = []
    for roomId in @roomKeys
      dayId = @Data.dayId( date, roomId )
      if        @days[dayId]?
        resId = @days[dayId].resId
        array .push( @resvs[resId] ) if @resvs[resId]?
    array

  resvArrayByProp:( beg, end, prop ) ->
    return  [] if not ( beg? and end? )
    resvs = {}
    array = []
    for roomId in @roomKeys
      date = beg
      while date <= end
        dayId = @Data.dayId( date, roomId )
        if        @days[dayId]?
          resId = @days[dayId].resId
          resvs[resId] = @resvs[resId] if @resvs[resId]?
        date = @Data.advanceDate( date, 1 )
    for own resId, resv of resvs
      array.push(  resv )
    @order = if @order is 'Decend' then 'Ascend' else 'Decend'
    Util.quicksort( array, prop, @order )

  resvSortDebug:( array, prop, order) ->
    #til.log( '------ Res.sortArray() xxx', { a:array[0][prop], b:array[3][prop], sort:@stringAscend( array[0], array[3] ) } )
    Util.log( array[i][prop] ) for i in [0...array.length]
    #array = @sortArray( array, prop, 'string', 'Ascend' )
    @order = if @order is 'Decend' then 'Ascend' else 'Decend'
    array = Util.quicksort( array, prop, order )
    Util.log( '------ Res.sortArray() end' )
    Util.log( array[i][prop] ) for i in [0...array.length]
    array




