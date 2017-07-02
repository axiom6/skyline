
class Data

  module.exports = Data

  @legacy      = ["unkn",   "canc",      "free",     "mine",   "prep",   "depo",   "chan",   "book",     "cnew",   "bnew"   ]
  @statuses    = ["Unknown","Cancel",    "Free",     "Mine",   "Prepaid","Deposit","Booking","Skyline",  "BookNew","SkylNew"]
  @colors      = ["#E8E8E8","#EEEEEE",   "#D3D3D3",  "#BBBBBB","#AAAAAA","#AAAAAA","#888888","#444444",  "#333333","#222222"]
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
Amber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833
Lynda Krupa 3 guests	31 July 2017	04 August 2017	Upper Skyline South	30 June 2017	OK	US$620	US$93	1652225524
Sara Zink 4 guests	04 August 2017	07 August 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1054573838
Ryan Mitchell 4 guests	18 August 2017	20 August 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1192666554
George Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856
Michael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744
"""
  @weird = """
Elisabetta Casali 16 guests	09 August 2017	11 August 2017	#4 One Room Cabin, #6 Large River Cabin	30 June 2017	OK	US$890	US$133.50	1563316762
Elisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958
"""

  @bookingResvsB = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Amber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833
Lynda Krupa 3 guests	31 July 2017	04 August 2017	Upper Skyline South	30 June 2017	OK	US$620	US$93	1652225524
Sara Zink 4 guests	04 August 2017	07 August 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1054573838
Elisabetta Casali 16 guests	09 August 2017	11 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	OK	US$890	US$133.50	1563316762
Elisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958
Ryan Mitchell 4 guests	18 August 2017	20 August 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1192666554
George Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856
Michael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744
Mary Hagen 2 guests	04 August 2017	06 August 2017	#4 One Room Cabin	29 June 2017	OK	US$290	US$43.50	1340661006
Steven Ravel 4 guests	28 July 2017	30 July 2017	Upper Skyline South	28 June 2017	OK	US$310	US$46.50	1217657012
Donna Bardallis 3 guests	28 July 2017	30 July 2017	#8 Western Unit	26 June 2017	OK	US$240	US$36	1368306301
Stephanie Hedgecock 8 guests	04 August 2017	06 August 2017	#3 Southwest Spa	24 June 2017	OK	US$630	US$94.50	1772131650
Melissa Seacreas 3 guests 1 guest message to answer	01 September 2017	04 September 2017	#8 Western Unit	24 June 2017	OK	US$360	US$54	1555046433
LAYLA YEAGER 12 guests 2 guest messages to answer	01 August 2017	03 August 2017	#6 Large River Cabin	22 June 2017	OK	US$630	US$94.50	1270507767
Laura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864
Karen Palmer 4 guests	18 August 2017	21 August 2017	#8 Western Unit	16 June 2017	OK	US$360	US$54	1747537592
Margaret Dreiling 1 guest	08 September 2017	10 September 2017	Upper Skyline South	15 June 2017	OK	US$310	US$46.50	1977820063
Sarah Troia 12 guests	04 August 2017	06 August 2017	#6 Large River Cabin	14 June 2017	OK	US$630	US$94.50	1175185436
Mohamed Basiouny 4 guests	19 August 2017	21 August 2017	Upper Skyline South	13 June 2017	OK	US$310	US$46.50	2008176523
karissa Wight 4 guests	07 September 2017	09 September 2017	#4 One Room Cabin	13 June 2017	OK	US$290	US$43.50	1779163724
Inez Cunningham 3 guests	07 September 2017	13 September 2017	#3 Southwest Spa	13 June 2017	OK	US$1890	US$283.50	1831513503
SHIU TAK LEUNG 2 guests	14 August 2017	17 August 2017	Upper Skyline South	12 June 2017	OK	US$465	US$69.75	1679266889
Tony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143
terrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222
Debbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879
ARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823
Terri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150
Carol Leech 4 guests	14 August 2017	16 August 2017	#8 Western Unit	07 June 2017	OK	US$260	US$39	1740250954
Virginia Clark 4 guests 1 guest message to answer	10 August 2017	13 August 2017	#8 Western Unit	06 June 2017	OK	US$390	US$58.50	1853252311
Todd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592
"""

  @Canceled = """Pauline McClendon 5 guests	25 August 2017	27 August 2017	#6 Large River Cabin	29 June 2017	Canceled	US$0	US$0	1335821435
Erma Henry 1 guest	31 July 2017	30 August 2017	#4 One Room Cabin	25 June 2017	Canceled	US$0	US$0	1225084642
Melissa Seacreas 3 guests	01 September 2017	04 September 2017	#8 Western Unit	23 June 2017	Canceled	US$0	US$0	1822387695
Stephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1120884797
vinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0	US$0	1438534254
susannah mitchell 1 guest	31 August 2017	03 September 2017	#1 One Room Cabin	04 June 2017	Canceled	US$0	US$0	1034276945
Gregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0	US$0	1357716307
Johnathan Koeltzow 2 guests	11 August 2017	13 August 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1756807815
clarice fenton 4 guests	22 July 2017	26 July 2017	Upper Skyline South	23 June 2017	Canceled	US$0	US$0	1538156772
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	Canceled	US$0	US$0	2079181490
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
T Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653
Han Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834
Lance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	Canceled	US$0	US$0	1919159565
"""

  @bookingResvsA = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Gregory Hebbler 2 guests	18 July 2017	25 July 2017	#5 Cabin with a View	28 June 2017	OK	US$1365	US$204.75	1643093209
Shivrajsinh Rana 3 guests	30 June 2017	03 July 2017	#8 Western Unit	28 June 2017	OK	US$360	US$54	1643057108
Thelma Carrera 3 guests	27 June 2017	29 June 2017	Upper Skyline South	27 June 2017	OK	US$310	US$46.50	1799824520
Jessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577
"""
