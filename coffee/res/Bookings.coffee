
class Bookings

  module.exports = Bookings

  @bookingResvs = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
David Oliver 4 guests	01 August 2017	03 August 2017	Upper Skyline North	11 July 2017	OK	US$330	US$49.50	1188635457
"""

  @bookingResvsE = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
"""

  @bookingMistake = """
Raza Mir 1 guest	09 July 2017	12 July 2017	#1 One Room Cabin	09 July 2017	OK	US$435	US$65.25	1915289977
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
"""

  @bookingResvsD = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Dezerae Poole 4 guests	13 July 2017	15 July 2017	#2 Mountain Spa	08 July 2017	OK	US$370	US$55.50	1472521885
Scott Frank 2 guests	17 July 2017	20 July 2017	#2 Mountain Spa	08 July 2017	OK	US$555	US$83.25	1404817650
juan pablo bours 8 guests	10 July 2017	12 July 2017	#3 Southwest Spa	04 July 2017	OK	US$630	US$94.50	1490587666
Teasa Baca 1 guest	14 July 2017	16 July 2017	#1 One Room Cabin	04 July 2017	OK	US$290	US$43.50	1461229119
Nick Russo 2 guests	11 July 2017	13 July 2017	#8 Western Unit	03 July 2017	OK	US$240	US$36	1251292752
louis maufrais 4 guests	13 July 2017	15 July 2017	#8 Western Unit	03 July 2017	OK	US$240	US$36	2051998205
Tyron Becker 4 guests	16 July 2017	20 July 2017	Upper Skyline North	03 July 2017	OK	US$660	US$99	1477467166
robert stone 2 guests	22 July 2017	24 July 2017	#5 Cabin with a View	03 July 2017	OK	US$390	US$58.50	1933816072
Roxane Romero 8 guests	14 July 2017	16 July 2017	#3 Southwest Spa	02 July 2017	OK	US$630	US$94.50	1297543429
Josh Murphy 4 guests	10 July 2017	12 July 2017	#5 Cabin with a View	01 July 2017	OK	US$390	US$58.50	1251493462
jay wills 4 guests	21 July 2017	23 July 2017	#2 Mountain Spa	01 July 2017	OK	US$370	US$55.50	1121958938
Amber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833
Michael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744
Steven Ravel 4 guests	28 July 2017	30 July 2017	Upper Skyline South	28 June 2017	OK	US$310	US$46.50	1217657012
Jessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577
Melissa Constantine 3 guests	24 July 2017	27 July 2017	#2 Mountain Spa	27 June 2017	OK	US$555	US$83.25	1217690885
Donna Bardallis 3 guests	28 July 2017	30 July 2017	#8 Western Unit	26 June 2017	OK	US$240	US$36	1368306301
Adam Broten 4 guests	21 July 2017	25 July 2017	Upper Skyline South	25 June 2017	OK	US$620	US$93	1619898321
Shuyan Qiu 4 guests	12 July 2017	14 July 2017	#4 One Room Cabin	21 June 2017	OK	US$290	US$43.50	1987323639
melissa larson 3 guests	15 July 2017	17 July 2017	#2 Mountain Spa	20 June 2017	OK	US$370	US$55.50	1559251465
Laura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864
Dennis Micheal Freiberg 2 guests	21 July 2017	23 July 2017	#8 Western Unit	17 June 2017	OK	US$240	US$36	1515589419
Scott Wilkins 4 guests	17 July 2017	21 July 2017	Upper Skyline South	15 June 2017	OK	US$620	US$93	1332065103
steven wolery 1 guest	17 July 2017	19 July 2017	#7 Western Spa	14 June 2017	OK	US$350	US$52.50	1082997039
Jonathan Calvin 5 guests	10 July 2017	13 July 2017	#6 Large River Cabin	13 June 2017	OK	US$945	US$141.75	1233373950
Carmel Contreras 4 guests	14 July 2017	16 July 2017	Upper Skyline North	12 June 2017	OK	US$330	US$49.50	1199985479
terrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222
Thomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793
Thomas Sturrock 12 guests 2 guest messages to answer	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110
Allison Mann 4 guests	23 July 2017	27 July 2017	#8 Western Unit	08 June 2017	OK	US$480	US$72	1529537163
Tiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563
Terri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150
Debra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572
Nirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416
Taylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994
Michael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266
Eric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525
Vanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051
Jeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580
"""

  @bookingResvsC  = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Marty Glynn 3 guests	03 August 2017	05 August 2017	#2 Mountain Spa	07 July 2017	OK	US$370	US$55.50	1637994103
ward bates 2 guests	07 August 2017	09 August 2017	#8 Western Unit	07 July 2017	OK	US$240	US$36	1179580200
William Burns 2 guests	10 August 2017	14 August 2017	Upper Skyline South	07 July 2017	OK	US$620	US$93	1609534921
Rachel Bryant 4 guests	18 August 2017	20 August 2017	#8 Western Unit	06 July 2017	OK	US$240	US$36	1154121605
mary bieber 12 guests	03 August 2017	05 August 2017	#6 Large River Cabin	05 July 2017	OK	US$600	US$90	1461242157
"""

  @canceled = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Lance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506
Han Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Gregory Hebbler 2 guests	18 July 2017	25 July 2017	#5 Cabin with a View	28 June 2017	Canceled	US$0	US$0	1643093209
clarice fenton 4 guests	22 July 2017	26 July 2017	Upper Skyline South	23 June 2017	Canceled	US$0	US$0	1538156772
T Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
Bradley Paul 4 guests	19 July 2017	21 July 2017	#8 Western Unit	06 July 2017	Canceled	US$0	US$0	1742527573
Isaias Denton 8 guests	17 July 2017	21 July 2017	#3 Southwest Spa	07 July 2017	Canceled	US$0	US$0	1903636043
Sandra Perea 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	04 July 2017	Canceled	US$0	US$0	2028271212
"""

  @canceledA = """
Erma Henry 2 guests	31 July 2017	30 August 2017	#4 One Room Cabin	25 June 2017	Canceled  US$0	US$0	1225084642
Karen Palmer 4 guests	18 August 2017	21 August 2017	#8 Western Unit	16 June 2017	Cancelled	US$0	US$0	1747537592
Pauline McClendon 5 guests	25 August 2017	27 August 2017	#6 Large River Cabin	29 June 2017	Cancelled	US$0	US$0	1335821435
Sandra Perea 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	04 July 2017	Canceled	US$0	US$0	2028271212
Sarah Troia 12 guests	04 August 2017	06 August 2017	#6 Large River Cabin	14 June 2017	Canceled	US$0	US$0	1175185436
Elisabetta Casali 12 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958
"""

  @bookingResvsB  = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
juan  bours 8 guests	10 July 2017	12 July 2017	#3 Southwest Spa	04 July 2017	OK	US$630	US$94.50	1490587666
Teasa Baca 1 guest	14 July 2017	16 July 2017	#1 One Room Cabin	04 July 2017	OK	US$290	US$43.50	1461229119
Nick Russo 2 guests	11 July 2017	13 July 2017	#8 Western Unit	03 July 2017	OK	US$240	US$36	1251292752
louis maufrais 4 guests	13 July 2017	15 July 2017	#8 Western Unit	03 July 2017	OK	US$240	US$36	2051998205
Tyron Becker 4 guests	16 July 2017	20 July 2017	Upper Skyline North	03 July 2017	OK	US$660	US$99	1477467166
robert stone 2 guests	22 July 2017	24 July 2017	#5 Cabin with a View	03 July 2017	OK	US$390	US$58.50	1933816072
Roxane Romero 8 guests	14 July 2017	16 July 2017	#3 Southwest Spa	02 July 2017	OK	US$630	US$94.50	1297543429
Josh Murphy 4 guests	10 July 2017	12 July 2017	#5 Cabin with a View	01 July 2017	OK	US$390	US$58.50	1251493462
jay wills 4 guests	21 July 2017	23 July 2017	#2 Mountain Spa	01 July 2017	OK	US$370	US$55.50	1121958938
mary bieber 12 guests	03 August 2017	05 August 2017	#6 Large River Cabin	05 July 2017	OK	US$600	US$90	1461242157
Sandra Perea 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	04 July 2017	Canceled	US$0	US$0	2028271212
Jim Husbands 4 guests	02 September 2017	04 September 2017	Upper Skyline North	05 July 2017	OK	US$330	US$49.50	1461288419
Melissa Seacreas 4 guests	01 September 2017	04 September 2017	#8 Western Unit	03 July 2017	OK	US$360	US$54	1180590619
Alberta Retana 2 guests	02 September 2017	04 September 2017	Upper Skyline South	02 July 2017	OK	US$310	US$46.50	1180598317
George Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856
Margaret Dreiling 1 guest	08 September 2017	10 September 2017	Upper Skyline South	15 June 2017	OK	US$310	US$46.50	1977820063
karissa Wight 4 guests	07 September 2017	09 September 2017	#4 One Room Cabin	13 June 2017	OK	US$290	US$43.50	1779163724
Inez Cunningham 3 guests	07 September 2017	13 September 2017	#3 Southwest Spa	13 June 2017	OK	US$1,890	US$283.50	1831513503
Tony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143
Todd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592
"""

  @bookingResvsA  = """
Guest name	Arrival	Departure	Room name	Booked on	Status	Total price	Commission	Reference number
susan settle 2 guests	12 August 2017	16 August 2017	#4 One Room Cabin	03 July 2017	OK	US$580	US$87	1791937613
Melissa Seacreas 4 guests	01 September 2017	04 September 2017	#8 Western Unit	03 July 2017	OK	US$360	US$54	1180590619
"""


  @canceledA = """Guest name	Arrival	Departure	Room name	Booked on	Status	Total price	Commission	Reference number
Melissa Seacreas 3 guests 1 guest message to answer	01 September 2017	04 September 2017	#8 Western Unit	24 June 2017	Canceled	US$0	US$0	1555046433
Melissa Seacreas 3 guests	01 September 2017	04 September 2017	#8 Western Unit	23 June 2017	Canceled	US$0	US$0	1822387695
Pauline McClendon 5 guests	25 August 2017	27 August 2017	#6 Large River Cabin	29 June 2017	Canceled	US$0	US$0	1335821435
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
  @weird = """
Erma Henry 1 guest	31 July 2017	30 August 2017	#4 One Room Cabin	25 June 2017	Canceled	US$0	US$0	1225084642
Elisabetta Casali 16 guests	09 August 2017	11 August 2017	#4 One Room Cabin, #6 Large River Cabin	30 June 2017	OK	US$890	US$133.50	1563316762
Elisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958
"""


