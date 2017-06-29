
class Data

  module.exports = Data

  @legacy      = ["free","mine","depo",   "book",   "prep",   "chan",   "canc"  ]
  @colors      = ["lightgrey","green","#555555","#000000","lightblue","blue",   "#999999","red",    "purple", "yellow" ]
  @statuses    = ["Free",     "Mine", "Deposit","Skyline","Prepaid",  "Booking","Cancel", "SkylNew","BookNew","Unknown"]
  @statusesSel = [                    "Deposit","Skyline","Prepaid",  "Booking","Cancel"]
  @sources     = ["Skyline","Booking","Website"]
  @tax         = 0.1055 # Official Estes Park tax rate. Also in Booking.com
  @season      = ["May","June","July","August","September","October"]
  @months      = ["January","February","March","April","May","June","July","August","September","October","November","December"]
  @months3     = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
  @numDayMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
  @weekdays    = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  @days        = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
  @persons     = ["1","2","3","4","5","6","7","8","9","10","11","12"]
  @nighti      = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14"]
  @pets        = ["0","1","2","3","4"]
  @petPrice    = 12
  @year        = 17
  @spaOptOut   = 20
  @monthIdx    = new Date().getMonth()
  @monthIdx    = if 4 <=  Data.monthIdx and Data.monthIdx <= 9 then Data.monthIdx else 4
  @month       = Data.months[Data.monthIdx]
  @newDays     =  3 # Number of  days to signify a new booking
  @numDays     = 15 # Display 15 days in Guest reservation calendar
  @begMay      = 15
  @begDay      = if Data.month is 'May' then Data.begMay else 1  # Being season on May 15
  @beg         = '170515'  # Beg seasom on May 15, 2017
  @end         = '171009'  # Beg seasom on Oct  9, 2017

  # npm -g install webpack@3.0.0 --save-dev

  @configSkytest = {
    apiKey: "AIzaSyAH4gtA-AVzTkwO_FXiEOlgDRK1rKLdJ2k",
    authDomain: "skytest-25d1c.firebaseapp.com",
    databaseURL: "https://skytest-25d1c.firebaseio.com",
    storageBucket: "skytest-25d1c.appspot.com",
    messagingSenderId: "978863515797" }

  @configSkyline = {
    apiKey:       "AIzaSyBjMGVzZ6JgZBs8O7mBQfH6clHYDmjTsGU",
    authDomain:   "skyline-fed2b.firebaseapp.com",
    databaseURL:  "https://skyline-fed2b.firebaseio.com",
    storageBucket: "skyline-fed2b.appspot.com/",
    messagingSenderId: "279547846849" }

  @toStatus:( status ) ->
    index = Data.legacy.indexOf(status)
    if index > 0 then Data.statuses[index] else status

  @toColor:( status ) ->
    index = Data.statuses.indexOf(status)
    if index > 0 then Data.colors[index] else "yellow"

  @config:( uri ) ->
    if uri is 'skyline' then @configSkyline else @configSkytest

  @databases = { skyline:"skyline-fed2b", skytest:"skytest-25d1c" }

  @stripeTestKey = "sk_test_FCa6Z3AusbsdhyV93B4CdWnV"
  @stripeTestPub = "pk_test_0VHIhWRH8hFwSeP2n084Ze4L"
  @stripeLiveKey = "sk_live_CCbj5oirIeHwTlyKVXJnbrgt"
  @stripeLivePub = "pk_live_Lb83wXgDVIuRoEpmK9ji2AU3"
  @stripeCurlKey = "sk_test_lUkwzunJkKfFmcEjHBtCfvhs"

  @resId:( date, roomId ) ->
    date + roomId

  @dayId:( date, roomId ) ->
    date + roomId

  @roomId:( anyId ) ->
    anyId.substr( 6, 1 )

  @getRoomIdFromNum:( num ) ->
    roomId = num
    roomId = 'N' if roomId is  9
    roomId = 'S' if roomId is 10
    roomId

  @toDate:( anyId ) ->
    if anyId?
      anyId.substr( 0, 6 )
    else
      Util

  @genResId:( roomUIs ) ->
    resId = ""
    for own roomId, roomUI of roomUIs when not Util.isObjEmpty(roomUI.days)
      days  = Util.keys(roomUI.days).sort()
      resId = days[0] + roomId
      break
    Util.error('Data.getResId() resId blank' ) if not Util.isStr(resId)
    resId

  @genCustId:( phone ) ->
    Util.padEnd( phone.substr(0,10), 10, '_' )

  @genPaymentId:( resId, payments ) ->
    pays   = Util.keys(payments).sort()
    paySeq = if pays.length > 0 then toString(parseInt(pays[pays.length-1])+1)  else '1'
    resId  + paySeq

  @randomCustKey:() ->
    Math.floor( Math.random() * (9999999999-1000000000)) + 1000000000

  @today:() ->
    date = new Date()
    year = date.getFullYear() - 2000 # Go Y2K
    Data.toDateStr( date.getDate(), date.getMonth(), year )

  @advanceDate:( date, numDays ) ->
    Util.trace( 'advanceDate', date ) if not Data.isDate(date)
    [yy,mi,dd] = @yymidd( date )
    dd += numDays
    if dd >       Data.numDayMonth[mi]
       dd  = dd - Data.numDayMonth[mi]
       mi++
    Data.toDateStr( dd, mi, yy )

  # Only good for a 28 to 30 day interval
  @nights:( arrive, depart ) ->
    num       = 0
    arriveDay = parseInt( arrive.substr( 4,2 ) )
    arriveMon = parseInt( arrive.substr( 2,2 ) )
    departDay = parseInt( depart.substr( 4,2 ) )
    departMon = parseInt( depart.substr( 2,2 ) )
    if      arriveMon   is departMon
      num = departDay - arriveDay
    else if arriveMon+1 is departMon
      num = Data.numDayMonth[arriveMon-1] - arriveDay + departDay
    Math.abs(num)

  @weekday:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    weekdayIdx = new Date( 2000+yy, mi, dd ).getDay()
    Data.weekdays[weekdayIdx]

  @isDate:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    valid  = true
    valid &= yy is Data.year
    valid &= 0 <= mi and mi <= 11
    valid &= 1 <= dd and dd <= 31
    valid

  @yymidd:( date ) ->
    yy = parseInt( date.substr( 0,2 ) )
    mi = parseInt( date.substr( 2,2 ) ) - 1
    dd = parseInt( date.substr( 4,2 ) )
    [yy,mi,dd]

  @toMMDD:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    Util.pad(mi+1) + '/' + Util.pad(dd)

  @toMMDD2:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    str = (mi+1).toString() + '/' + dd.toString()
    Util.log( 'Data.toMMDD()', date, yy, mi, dd, str )
    str

  @isElem:( $elem ) ->
    not (  $elem? and $elem.length? and $elem.length is 0 )

  @dayMonth:( day ) ->
    monthDay = day + Data.begDay - 1
    if monthDay > Data.numDayMonth[@monthIdx] then monthDay-Data.numDayMonth[Data.monthIdx] else monthDay

  @toDateStr:( dd, mi=Data.monthIdx, yy=Data.year ) ->
    yy.toString() + Util.pad(mi+1) + Util.pad(dd)

  @toMonth3DayYear:( date ) ->
    [yy,mi,dd] = if Data.isDate(date) then @yymidd(date) else @yymidd(Data.today())
    Util.log( 'Data.yymidd()', date, yy, mi, dd )
    Data.months3[mi] + dd.toString() + ', ' + (2000+yy).toString()

  @bookingResvs = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Gregory Hebbler 2 guests	18 July 2017	25 July 2017	#5 Cabin with a View	28 June 2017	OK	US$1365	US$204.75	1643093209
"""

  @bookingResvsA = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Gregory Hebbler 2 guests	18 July 2017	25 July 2017	#5 Cabin with a View	28 June 2017	OK	US$1365	US$204.75	1643093209
Shivrajsinh Rana 3 guests	30 June 2017	03 July 2017	#8 Western Unit	28 June 2017	OK	US$360	US$54	1643057108
Thelma Carrera 3 guests	27 June 2017	29 June 2017	Upper Skyline South	27 June 2017	OK	US$310	US$46.50	1799824520
Jessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577
"""
