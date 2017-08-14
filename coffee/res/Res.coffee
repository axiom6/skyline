
Data = require( 'js/res/Data' )
UI   = require( 'js/res/UI'   )

class Res

  module.exports = Res
  Res.Rooms = require( 'data/room.json' )
  Res.Sets  = ['full','book','resv','chan']  # Data set for @res.days and @res.resv

  constructor:( @stream, @store, @appName ) ->
    @rooms     = Res.Rooms
    @roomKeys  = Util.keys( @rooms )
    @book      = null
    @master    = null
    @days      = {}
    @resvs     = {}
    @cans      = {}
    @order     = 'Decend'
    @today     = Data.today()

  dateRange:( beg, end, onComplete=null ) ->
    @store.subscribe( 'Day', 'range', 'none', (days) =>
      @days = days
      day.status = Data.toStatus(day.status) for own dayId, day of @days
      onComplete() if Util.isFunc(onComplete) )
    @store.range( 'Day', beg+'1', end+'S' )
    return

  selectAllDays:( onComplete=null ) ->
    @store.subscribe( 'Day', 'select', 'none', (days) =>
      @days = days
      #day.status = Data.toStatus(day.status) for own dayId, day of @days
      onComplete() if Util.isFunc(onComplete) )
    @store.select( 'Day' )
    return

  selectAllResvs:( onComplete=null, genDays=false ) =>
    @store.subscribe( 'Res', 'select', 'none', (resvs) =>
      @resvs = resvs
      if genDays
        @updateDaysFromResv( resv, false ) for own resId, resv of @resvs
      onComplete() if Util.isFunc(onComplete) ) # resvs not passed to onComplete() - accesss @resvs later on
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
    nights = Data.nights( resv.booked, @today )
    nights < Data.newDays

  status:( date, roomId ) ->
    dayId = Data.dayId( date, roomId )
    day   = @days[dayId]
    st    = if day? then day.status else 'Free'
    #Util.trace( 'Res.status', st ) if not Util.isStr(st) or st is 'Unknown'
    st

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
    #Util.log( 'Res.getResv', date, roomId, day ) if day?
    if day? then @resvs[day.resId] else null

  day:( date, roomId ) ->
    dayId = Data.dayId( date, roomId )
    day   = @days[dayId]
    if day? then day else @setDay( {}, 'Free', 'none', dayId )

  dayIds:( arrive, stayto, roomId ) ->
    depart = Data.advanceDate( stayto, 1 )
    nights = Data.nights( arrive, depart )
    ids = []
    for i in [0...nights]
      ids.push( Data.dayId( Data.advanceDate( arrive, i ), roomId ) )
    ids

  datesFree:(         arrive, stayto, roomId, resv ) ->
    dayIds = @dayIds( arrive, stayto, roomId )
    for dayId in dayIds
      if @days[dayId]? and not ( @days[dayId].status is 'Free' or @days[dayId].resId is resv.resId )
        Util.log( 'Res.collision days', { arrive:arrive,      stayto:stayto,      roomId:roomId,      dayId:dayId    } )
        Util.log( 'Res.collision resv', { arrive:resv.arrive, stayto:resv.stayto, roomId:resv.roomId, name:resv.last } )
        return false
    true

  allocDays:( days ) ->
    @book.  allocDays( days ) if @book?
    @master.allocDays( days ) if @master?
    return

  allocResv:( resv ) ->
    @book.  allocResv( resv ) if @book?
    @master.allocResv( resv ) if @master?
    return

  updateResvs:( newResvs ) ->
    for own resId, resv of newResvs
      @addResv( resv )
    @resvs

  updateCancels:( newCancels ) ->
    for own resId, can of newCancels
      @addCan( can )
    @resvs

  daysFromResv:( resv ) ->
    days = {} # resv days
    for i in [0...resv.nights]
      dayId       = Data.dayId( Data.advanceDate( resv.arrive, i ), resv.roomId )
      days[dayId] = @setDay( {}, resv.status, resv.resId, dayId )
    days

  deleteDaysFromResv:( resv ) ->
    days = @daysFromResv( resv )
    for dayId, day of days
      day.status = 'Free'
    @allocDays( days )
    @allocResv( resv )
    for dayId, day of days
      @delDay( day )
    return

  updateDaysFromResv:( resv, add=true ) ->
    days = @daysFromResv( resv )
    @allocDays( days )
    @allocResv( resv )
    for dayId, day of days
      @addDay( day )
    return

  calcPrice:( roomId, guests, pets, status ) ->
    #Util.log( 'Res.calcPrice()', { roomId:roomId, guests:guests, pets:pets, guestprice:@rooms[roomId][guests], petfee:pets*Data.petPrice  } )
    if status is 'Booking' or status is 'Prepaid'
      @rooms[roomId].booking
    else
      @rooms[roomId][guests] + pets*Data.petPrice

  spaOptOut:( roomId, isSpaOptOut=true ) ->
    if @rooms[roomId].spa is 'O' and isSpaOptOut then Data.spaOptOut else 0

  genDates:( arrive, nights ) ->
    dates = {}
    for i in [0...nights]
      date = Data.advanceDate( arrive, i )
      dates[date] = ""
    dates

  # .... Creation ........

  total:( status, nights, roomId, guests, pets=0 ) ->
    tot = 0
    if status is 'Skyline'
      tot = nights * ( @rooms[roomId][guests] + pets * Data.petPrice )
    else
      tot = nights *   @rooms[roomId].booking
    tot

  createResvSkyline:( arrive, depart, roomId, last, status, guests, pets, spa=false, cust={}, payments={} ) ->
    booked = Data.today()
    price  = @rooms[roomId][guests] + pets*Data.petPrice
    nights = Data.nights( arrive, depart )
    total  = price * nights
    @createResv( arrive, depart, booked, roomId, last, status, guests, pets, 'Skyline', total, spa, cust, payments )

  createResvBooking:( arrive, depart, roomId, last, status, guests, total, booked ) ->
    total  = if total is 0 then @rooms[roomId].booking * Data.nights( arrive, depart ) else total
    pets   = 0
    @createResv( arrive, depart, booked, roomId, last, status, guests, pets, 'Booking', total )

  createResv:( arrive, depart, booked, roomId, last, status, guests, pets, source, total, spa=false, cust={}, payments={} ) ->
    resv           = {}
    resv.nights    = Data.nights( arrive, depart )
    resv.arrive    = arrive
    resv.depart    = depart
    resv.booked    = booked
    resv.stayto    = Data.advanceDate( arrive, resv.nights - 1 )
    resv.roomId    = roomId
    resv.last      = last
    resv.status    = status
    resv.guests    = guests
    resv.pets      = pets
    resv.source    = source
    resv.resId     = Data.resId( arrive, roomId )
    resv.total     = total
    resv.price     = total / resv.nights
    resv.tax       = Util.toFixed( total * Data.tax )
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
    cust.custId = Data.genCustId( phone )
    cust.first  = first
    cust.last   = last
    cust.phone  = phone
    cust.email  = email
    cust.source = source
    cust

  createPayment:( amount, method, last4, purpose ) ->
    payment = {}
    payment.amount  = amount
    payment.date    = Data.today()
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
    @store.subscribe( table, 'insert', 'none', (rows) => onComplete(rows) if Util.isFunc(onComplete) )
    @store.insert(    table,  rows )
    return

  select:( table, rows, onComplete=null ) =>
    @store.subscribe( table, 'select', 'none', (rows) => onComplete(rows) if Util.isFunc(onComplete) )
    @store.select(    table )
    return

  make:( table, rows, onComplete=null ) ->
    @store.subscribe( table, 'make', 'none', ()  => @insert( table, rows, onComplete() if Util.isFunc(onComplete) ) )
    @store.make( table )
    return

  ###
  makeTables:() ->
    @make( 'Room', Res.Rooms )
    @store.make( 'Res' )
    @store.make( 'Day' )
    return

  # Destroys whole data base up to root
  dropMakeTable:( table ) ->
    @store.subscribe( table, 'drop', 'none', () => @store.make(table) )
    @store.drop( table )
    return
  ###

  setResvStatus:( resv, post, purpose ) ->
    if        post is 'post'
        resv.status = 'Skyline' if purpose is 'PayInFull' or purpose is 'Complete'
        resv.status = 'Deposit' if purpose is 'Deposit'
    else if   post is 'deny'
        resv.status = 'Free'
    if not Util.inArray(Data.statuses, resv.status )
      Util.error( 'Pay.setResStatus() unknown status ', resv.status )
      resv.status = 'Free'
    resv.status

  addResv:( resv ) ->
    @resvs[resv.resId] = resv
    @store.add( 'Res', resv.resId, resv )
    return

  putResv:( resv ) ->
    Util.error('Res.putResv resv null') if not resv?
    @resvs[resv.resId] = resv
    @store.put( 'Res', resv.resId, resv )
    return

  delResv:( resv ) ->                     
    delete @resvs[resv.resId]
    @store.del( 'Res', resv.resId )
    return

  addCan:( can ) ->
    can['cancel'] = @today
    @cans[can.resId] = can
    @store.add( 'Can', can.resId, can )
    return
    
  putCan:( can ) ->                     
    @resvs[can.resId] = can
    @store.put( 'Can', can.resId, can ) # We do a put
    return

  delCan:( can ) ->
    delete @cans[can.resId]
    @store.del( 'Can', can.resId )
    return

  addDay:( day ) ->
    if day.status isnt 'Unknown'

      @days[day.dayId] = day
      @store.add( 'Day', day.dayId, day )
    else
      Util.error( 'Unknown day', day )
      Util.error( 'Checkon res', @resvs[day.resId] )
    return

  putDay:( day ) ->
    @days[day.dayId] = day
    @store.put( 'Day', day.dayId, day )
    return

  delDay:( day ) ->
    delete @days[day.dayId]
    @store.del( 'Day', day.dayId )
    return

  postPayment:( resv, post, amount, method, last4, purpose ) ->
    status = @setResvStatus( resv, post, purpose )
    if status is 'Skyline' or status is 'Deposit'
      payId = Data.genPaymentId( resv.resId, resv.payments )
      resv.payments[payId] = @createPayment( amount, method, last4, purpose )
      resv.paid   += amount
      resv.balance = resv.totals - resv.paid
      @postResv( resv )
    return

  # Used for Days / dayId / roomId and for Res / rooms[dayId] since both has status and resid properties
  setDay:( day, status, resId, dayId ) ->
    day.status = status
    day.resId  = resId
    day.dayId  = dayId
    day

  # ......Utilities ......

  optSpa:( roomId ) -> @rooms[roomId].spa is 'O'
  hasSpa:( roomId ) -> @rooms[roomId].spa is 'O' or @rooms[roomId].spa is 'Y'

  # ...... UI Elements that does not quite belong here .....

  # Query

  resvArrayByDate:( date ) ->
    array  = []
    for roomId in @roomKeys
      dayId = Data.dayId( date, roomId )
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
        dayId = Data.dayId( date, roomId )
        if        @days[dayId]?
          resId = @days[dayId].resId
          resvs[resId] = @resvs[resId] if @resvs[resId]?
        date = Data.advanceDate( date, 1 )
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




