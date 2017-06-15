
$ = require( 'jquery' )

class Res

  module.exports = Res
  Res.Rooms = require( 'data/room.json' )
  Res.Sets  = ['full','book','resv','chan']  # Data set for @res.days and @res.resv

  constructor:( @stream, @store, @Data, @appName ) ->
    @rooms    = Res.Rooms
    @roomKeys = Util.keys( @rooms )
    @book     = null
    @master   = null
    @days     = {}
    @resvs    = {}
    @dateRange( @Data.beg, @Data.end ) if @appName is 'Guest' # Get entire season for both Guest and Owner
    #@makeTables()
    #@populateMemory()      if @store.justMemory

  # Needs work
  populateMemory:() ->
    @onRes(  'add', (resv) => Util.noop( 'onRes', resv ) )
    @onDay(  'put', (days) => Util.noop( 'onDay', days ) ) if @store.justMemory
    @makeTables() # Populate Memory

  dateRange:( beg, end, onComplete=null ) ->
    @store.subscribe( 'Day', 'range', 'none', (days) =>
      @days = days
      onComplete() if onComplete? )
    @store.range( 'Day', beg+'1', end+'S' )
    return

  selectAllDays:( onComplete=null ) ->
    @store.subscribe( 'Day', 'select', 'none', (days) =>
      @days = days
      onComplete() if onComplete? )
    @store.select( 'Day' )

  selectAllResvs:( onComplete=null ) ->
    @store.subscribe( 'Res', 'select', 'none', (resvs) =>
      @resvs = resvs
      onComplete() if onComplete? ) # resvs not passed to onComplete() - accesss @resvs later on
    @store.select( 'Res' )

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

  status:( date, roomId ) ->
    dayId = @Data.dayId( date, roomId )
    day   = @days[dayId]
    if day? then day.status else 'free'

  day:( date, roomId ) ->
    dayId = @Data.dayId( date, roomId )
    day   = @days[dayId]
    if day? then day else @setDay( {}, 'free', 'none' )

  dayIds:( arrive, stayto, roomId ) ->
    depart = Data.advanceDate( stayto, 1 )
    nights = @Data.nights( arrive, depart )
    ids = []
    for i in [0...nights]
      ids.push( @Data.dayId( @Data.advanceDate( arrive, i ), roomId ) )
    ids

  resIds:( arrive, stayto, roomId ) ->
    depart = @Data.advanceDate( stayto, 1      )
    nights = @Data.nights(      arrive, depart )
    ids = []
    for i in [0...nights]
      dayId = @Data.dayId( @Data.advanceDate( arrive, i ), roomId )
      ids.push( @days[dayId].resId ) if @days[dayId]? and not Util.inArray( ids, @days[dayId].resId )
    Util.log( 'Res.resIds()', { arrive:arrive, stayto:stayto, depart:depart, roomId:roomId, nights:nights, ids:ids } )
    ids

  resvRange:( beg, end ) ->
    resvs  = {}
    resIds = []
    resIds.push( @resIds( beg, end, roomId ) ) for roomId in @roomKeys
    resvs[resId] = @resvs[resId]               for resId  in resIds when @resvs[resId]?
    resvs

  allocDays:( days ) ->
    @book.  allocDays( days ) if @book?
    @master.allocDays( days ) if @master?
    return

  updateResvs:( newResvs ) ->
    for own  resId,   resv of newResvs
      @resvs[resId] = resv
      @postResv(      resv )
    @resvs

  updateDaysFromResv:( resv ) ->
    Util.log( 'Res', resv )
    days = {} # resv days
    for i in [0...resv.nights]
      dayId       = @Data.dayId( @Data.advanceDate( resv.arrive, i ), resv.roomId )
      days[dayId] = @setDay( {}, resv.status, resv.resId )
    @allocDays(     days )
    #@insert( 'Day', days ) # (days) => Util.log('Day', days )
    for dayId, day of days
      Util.log( 'Day',   dayId, day )
      @store.add( 'Day', dayId, day )
      @days[dayId] = day
    return

  calcPrice:( roomId, guests, pets  ) ->
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

  createResvBooking:( arrive, depart, booked, roomId, last, status, guests, total ) ->
    total  = if total is 0 then @rooms[roomId].booking * @Data.nights( arrive, depart ) else total
    pets   = '?'
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

  onResId:( op, doResv, resId ) => @store.on( 'Res', op,  resId, (resv) => doResv(resv) )
  onRes:(   op, doResv        ) => @store.on( 'Res', op, 'none', (resv) => doResv(resv) )
  onDay:(   op, doDay         ) => @store.on( 'Day', op, 'none', (day)  => doDay(day)   )

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
        resv.status = 'book' if purpose is 'PayInFull' or purpose is 'Complete'
        resv.status = 'depo' if purpose is 'Deposit'
    else if   post is 'deny'
        resv.status = 'free'
    if not Util.inArray(['book','depo','free'], resv.status )
      Util.error( 'Pay.setResStatus() unknown status ', resv.status )
      resv.status = 'free'
    resv.status

  postResv:( resv ) ->
    @store.add( 'Res', resv.resId, resv )

  postPayment:( resv, post, amount, method, last4, purpose ) ->
    status = @setResvStatus( resv, post, purpose )
    if status is 'book' or status is 'depo'
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
  htmlInput:( htmlId, klass, value="", label="", type="text" ) ->
    htm  = ""
    htm += """<label for="#{htmlId}" class="#{klass+'Label'}">#{label}</label>"""  if Util.isStr(label)
    htm += """<input id= "#{htmlId}" class="#{klass}" value="#{value}" type="#{type}">"""
    htm

  htmlButton:( htmlId, klass, title ) ->
    """<button id="#{htmlId}" class="btn btn-primary #{klass}">#{title}</button>"""

  # Sets htmlId property on obj
  makeSelect:( htmlId, obj ) =>
    onSelect = (event) -> obj[htmlId] = $(event.target).value
    $('#'+htmlId).change( onSelect )
    return

  # Sets htmlId property on obj
  makeInput:( htmlId, obj ) =>
    onInput = (event) -> obj[htmlId] = $(event.target).value # $('#'+htmlId).val()
    $('#'+htmlId).change( onInput )
    return

