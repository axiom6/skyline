
class Data

  module.exports = Data

  @legacy      = ["unkn",   "canc",      "free",     "mine",   "prep",   "depo",   "chan",   "book",     "cnew",   "bnew"   ]
  @statuses    = ["Unknown","Cancel",    "Free",     "Mine",   "Prepaid","Deposit","Booking","Skyline",  "BookNew","SkylNew"]
  @colors      = ["#E8E8E8","#EEEEEE",   "#FFFFFF",  "#BBBBBB","#AAAAAA","#AAAAAA","#888888","#444444",  "#333333","#222222"]
  @colors1     = ["yellow", "whitesmoke","lightgrey","green",  "#555555","#000000","blue",   "slategray","purple", "black"  ]
  @statusesSel = ["Deposit","Skyline","Prepaid",  "Booking","Cancel"]
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
  @newDays     =  3 # Number of  days to signify a new booking
  @numDays     = 15 # Display 15 days in Guest reservation calendar
  @begMay      = 15
  @begDay      = if Data.monthIdx is 4 then Data.begMay else 1  # Being season on May 15
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

  @month:() ->
    Data.months[Data.monthIdx]

  @numDaysMonth:( month=Data.month() ) ->
     mi = Data.months.indexOf(month)
     Data.numDayMonth[mi]

  @advanceDate:( date, numDays ) ->
    [yy,mi,dd] = @yymidd( date )
    dd += numDays
    if dd >       Data.numDayMonth[mi]
       dd  = dd - Data.numDayMonth[mi]
       mi++
    else if dd < 1
      mi--
      dd  = Data.numDayMonth[mi]
    Data.toDateStr( dd, mi, yy )

  @advanceMMDD:( mmdd, numDays ) ->
    [mi,dd] = @midd( mmdd )
    dd += numDays
    if dd >       Data.numDayMonth[mi]
       dd  = dd - Data.numDayMonth[mi]
       mi++
    else if dd < 1
       mi--
       dd  = Data.numDayMonth[mi]
    Util.pad(mi+1) + '/' + Util.pad(dd)

  # Only good for a 28 to 30 day interval
  @nights:( arrive, stayto ) ->
    num       = 0
    arriveDay = parseInt( arrive.substr( 4,2 ) )
    arriveMon = parseInt( arrive.substr( 2,2 ) )
    staytoDay = parseInt( stayto.substr( 4,2 ) )
    staytoMon = parseInt( stayto.substr( 2,2 ) )
    if      arriveMon   is staytoMon
      num = staytoDay - arriveDay + 1
    else if arriveMon+1 is staytoMon
      num = Data.numDayMonth[arriveMon-1] - arriveDay + staytoDay + 1
    Math.abs(num)

  @weekday:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    weekdayIdx = new Date( 2000+yy, mi, dd ).getDay()
    Data.weekdays[weekdayIdx]

  @isDate:( date ) ->
    return false if not Util.isStr(date) or date.length isnt 6
    [yy,mi,dd] = @yymidd( date )
    valid  = true
    valid &= yy is Data.year
    valid &= 0 <= mi and mi <= 11
    valid &= 1 <= dd and dd <= 31
    valid

  @begEndDates:(  begDate1,   endDate1 ) ->
    return [null,null] if not ( begDate1? and endDate1? )
    begDate2 = if begDate1 <= endDate1 then begDate1 else endDate1
    endDate2 = if endDate1 >  begDate1 then endDate1 else begDate1
    [begDate2,endDate2]

  @yymidd:( date ) ->
    yy = parseInt( date.substr( 0,2 ) )
    mi = parseInt( date.substr( 2,2 ) ) - 1
    dd = parseInt( date.substr( 4,2 ) )
    [yy,mi,dd]

  @midd:( mmdd ) ->
    mi = parseInt( mmdd.substr( 0,2 ) ) - 1
    dd = parseInt( mmdd.substr( 3,2 ) )
    [mi,dd]

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
