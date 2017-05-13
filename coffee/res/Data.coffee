
class Data

  module.exports = Data

  @insertNewTables = false # Use Res test data

  @year        = 17
  @season      = ["May","June","July","August","September","October"]
  @months      = ["January","February","March","April","May","June","July","August","September","October","November","December"]
  @numDayMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
  @weekdays    = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  @days        = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
  @persons     = ["1","2","3","4","5","6","7","8","9","10","11","12"]
  @pets        = ["0","1","2","3","4"]
  @petPrice    = 12

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

  @databases = { skyline:"skyline-fed2b", skytest:"skytest-25d1c" }

  @stripeTestKey = "sk_test_FCa6Z3AusbsdhyV93B4CdWnV"
  @stripeTestPub = "pk_test_0VHIhWRH8hFwSeP2n084Ze4L"
  @stripeLiveKey = "sk_live_CCbj5oirIeHwTlyKVXJnbrgt"
  @stripeLivePub = "pk_live_Lb83wXgDVIuRoEpmK9ji2AU3"
  @stripeCurlKey = "sk_test_lUkwzunJkKfFmcEjHBtCfvhs"

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
    year  = date.getFullYear().toString()
    month = Util.padStr( date.getMonth()+1 )
    day   = Util.padStr( date.getDate()    )
    #Util.log( 'Data.today', year, month, day, year + month + day )
    year + month + day

  @advanceDate:( resDate, numDays ) ->
    year     =           resDate.substr( 0,2 )
    monthIdx = parseInt( resDate.substr( 2,2 ) ) - 1
    dayInt   = parseInt( resDate.substr( 4,2 ) ) + numDays
    if dayInt > @numDayMonth[monthIdx]
       dayInt = dayInt - @numDayMonth[monthIdx]
       monthIdx++
    day   = Util.padStr( dayInt     )
    month = Util.padStr( monthIdx+1 )
    #Util.log( 'Data.advanceDate', resDate, year + month + day )
    year + month + day

  @weekday:( date ) ->
    year       = parseInt( date.substr( 0,2 ) )
    monthIdx   = parseInt( date.substr( 2,2 ) ) - 1
    dayInt     = parseInt( date.substr( 4,2 ) )
    weekdayIdx = new Date( 2000+year, monthIdx, dayInt ).getDay()
    Data.weekdays[weekdayIdx]



  @isElem:( $elem ) ->
    not (  $elem? and $elem.length? and $elem.length is 0 )


