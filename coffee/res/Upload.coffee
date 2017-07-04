
$ = require( 'jquery'  )

class Upload

  module.exports = Upload

  constructor:( @stream, @store, @Data, @res ) ->
    @uploadedText  = ""
    @uploadedResvs = {}

  html:() ->
    htm  = ""
    htm += """<h1 class="UploadH1">Upload Booking.com</h1>"""
    htm += """<button id="UpdateRes" class="btn btn-primary">Update Res</button>"""
    htm += """<textarea id="UploadText" class="UploadText" rows="50" cols="100"></textarea>"""
    htm

  bindUploadPaste:() ->
    onPaste = (event) =>
      if window.clipboardData and window.clipboardData.getData # IE
        @uploadedText = window.clipboardData.getData('Text')
      else if event.clipboardData and event.clipboardData.getData
        @uploadedText = event.clipboardData.getData('text/plain')
      event.preventDefault()
      if Util.isStr(    @uploadedText )
         @uploadedResvs = @uploadParse(  @uploadedText )
         $('#UploadText').text( @uploadedText )
    document.addEventListener( "paste", onPaste )

  uploadParse:( text ) ->
    resvs   = {}
    return resvs if not Util.isStr( text )
    lines = text.split('\n')
    for line in lines
      toks = line.split('\t')
      continue if toks[0] is 'Guest name'
      book   = @bookFromToks( toks )
      resv   = @resvFromBook( book )
      resvs[resv.resId ] = resv
    resvs

  bookFromToks:( toks ) ->
    book           = {}
    book.names     = toks[0]
    book.arrive    = toks[1]
    book.depart    = toks[2]
    book.room      = toks[3]
    book.booked    = toks[4]
    book.status    = toks[5]
    book.total     = toks[6]
    book.commis    = toks[7]
    book.bookingId = toks[8]
    #Util.log( 'Book......')
    #Util.log(  book )
    book

  resvFromBook:( book ) ->
    names  = book.names.split(' ')
    arrive = @toResvDate( book.arrive )
    depart = @toResvDate( book.depart )
    booked = @toResvDate( book.booked )
    roomId = @toResvRoomId( book.room )
    #first = names[0]
    last   = names[1]
    status = @toStatus(   book.status )
    guests = @toNumGuests( names )
    total  = parseFloat( book.total.substr(3) )
    @res.createResvBooking( arrive, depart, roomId, last, status, guests, total, booked )

  onUpdateRes:() =>

    if not Util.isStr( @uploadedText )
      @uploadedText  = @Data.bookingResvs
      @uploadedResvs = @uploadParse(  @uploadedText )
      $('#UploadText').text( @uploadedText )

    return if Util.isObjEmpty(    @uploadedResvs )
    return if not @updateValid(   @uploadedResvs )
    @res.updateResvs(             @uploadedResvs )
    @uploadedResv = {}

  updateValid:( uploadedResvs ) ->
    valid = true
    for own resId, u of uploadedResvs
      u.v  = true
      #.v &= Util.isStr( u.first )
      u.v &= Util.isStr( u.last  )
      u.v &= 1 <= u.guests and u.guests <= 12
      u.v &= @Data.isDate( u.arrive )
      u.v &= @Data.isDate( u.depart )
      u.v &= if typeof(pets) is 'number' then 0 <= u.pets   and u.pets   <=  4 else true
      u.v &= 0 <= u.nights and u.nights <= 28
      u.v &= Util.inArray( @res.roomKeys, u.roomId )
      u.v &=   0.00 <= u.total and u.total <= 8820.00
      u.v &= 120.00 <= u.price and u.price <=  315.00
      valid &= u.v
      #Util.log( 'Resv......', u.v )
      #Util.log(  u )
    Util.log( 'Master.updateValid()', valid )
    true

  toNumGuests:( names ) ->
    for i in [0...names.length] when names[i] is 'guest' or names[i] is 'guests'
      return names[i-1]
    return '0' # This will invalidate

  toResvDate:( bookDate ) ->
    toks  = bookDate.split(' ')
    year  = @Data.year
    month = @Data.months.indexOf(toks[1]) + 1
    day   = toks[0]
    year.toString() + Util.pad(month) + day

  toResvRoomId:( bookRoom ) ->
    toks  = bookRoom.split(' ')
    if toks[0].charAt(0) is '#'
       toks[0].charAt(1)
    else
       toks[2].charAt(0)

  toStatus:( bookingStatus ) ->
    switch   bookingStatus
      when 'OK'       then 'Booking'
      when 'Canceled' then 'Cancel'
      else                 'Unknown'