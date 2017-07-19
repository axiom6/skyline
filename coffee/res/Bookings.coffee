
class Bookings

  module.exports = Bookings

  @june = """
06/30 07/02 3 7 Woods 1 Booking 06/16 $175 $525 $55.39 $580.39
06/30 07/02 3 8 Rana 3 Booking 06/28 $120 $360 $37.98 $397.98
06/30 07/02 3 S Hota 4 Booking 06/01 $155 $465 $49.06 $514.06
06/29 07/06 8 2 Pachner 4 Booking 06/05 $185 $1480 $156.14 $1636.14
06/29 06/30 2 N Han 4 Skyline 06/29 $165 $330 $34.81 $364.81
06/28 06/30 3 5 Haynes 3 Booking 06/12 $195 $585 $61.72 $646.72
06/27 06/28 2 8 Nepal 4 Booking 06/06 $130 $260 $27.43 $287.43
06/26 06/29 4 4 FREEMAN 4 Booking 06/06 $145 $580 $61.19 $641.19
06/25 06/26 2 2 Green 4 Booking 06/01 $185 $370 $39.03 $409.03
06/25 06/29 5 3 Contractors 4 Skyline 06/28 $275 $1375 $145.06 $1520.06
06/25 06/27 3 N b 4 Skyline 06/21 $165 $495 $52.22 $547.22
06/23 06/24 2 1 Lofstrom 1 Booking 06/01 $145 $290 $30.59 $320.59
06/23 06/24 2 2 CUI 2 Booking 06/13 $185 $370 $39.03 $409.03
06/23 06/24 2 3 Chan;Che 8 Booking 06/04 $315 $630 $66.47 $696.47
06/23 06/25 3 4 Roper 4 Booking 05/31 $145 $435 $45.89 $480.89
06/23 06/24 2 5 Segura 4 Booking 06/11 $195 $390 $41.14 $431.14
06/23 06/24 2 7 b 4 Skyline 06/21 $175 $350 $36.92 $386.92
06/23 06/24 2 N Thomas 2 Booking 06/03 $165 $330 $34.81 $364.81
06/23 06/24 2 S Shuck 4 Booking 06/01 $155 $310 $32.70 $342.70
06/22 06/22 1 8 b 4 Skyline 06/21 $120 $120 $12.66 $132.66
06/21 06/22 2 2 b 4 Skyline 06/21 $185 $370 $39.03 $409.03
06/21 06/22 2 3 b 4 Skyline 06/21 $275 $550 $58.02 $608.02
06/21 06/22 2 5 b 4 Skyline 06/21 $195 $390 $41.14 $431.14
06/21 06/30 10 6 b 4 Skyline 06/21 $300 $3000 $316.50 $3316.50
06/20 06/21 2 4 Rutledge 4 Booking 06/22 $145 $290 $30.59 $320.59
06/18 06/19 2 4 Ross 4 Booking 06/10 $145 $290 $30.59 $320.59
06/18 06/20 3 8 Schwindt 4 Booking 06/08 $120 $360 $37.98 $397.98
06/16 06/17 2 2 Carpenter 2 Booking 06/15 $185 $370 $39.03 $409.03
06/16 06/17 2 8 Nelsen 4 Booking 06/03 $145 $290 $30.59 $320.59
06/16 06/17 2 N Price 3 Booking 06/08 $165 $330 $34.81 $364.81
06/16 06/17 2 S peterson 4 Booking 06/06 $155 $310 $32.70 $342.70
"""
  @kuly18 = """
6/29 7/6 2 Pachner 4 B 6/05 $185
6/30 7/2 5 Hota    4 B 6/01 $155
"""

  @july19 = """
1 1 1 3 Contractor 4 S 06/28
1 4 1 4 x 4 S 06/21
1 3 1 5 Name? 4 S 06/28
1 2 1 7 Woods 4 S 06/29
1 2 1 8 Rana 4 B 06/29
1 3 1 N Diachuk 2 B 06/03
2 4 1 3 Markottor 8 B 06/29
2 4 1 6 Fiffen 4 S 06/29
3 6 1 1 Who 4 S 07/06
3 7 1 7 Bonnel 1 B 06/09
3 5 1 8 Block 4 S 06/29
3 6 1 S Kile 4 B 06/06
4 5 1 S Carrera 4 B 06/28
4 6 1 N Feldewert 2 B 06/22
5 7 1 4 Costilo 4 S 06/27
5 8 1 6 Kroger 12 B 06/02
7 11 1 2 Shinn 3 B 06/21
7 9 1 5 Brent 4 S 07/06
7 8 1 8 Preiss 2 B 06/21
7 9 1 N Chitty 2 B 06/23
7 8 1 S South 2 B 06/20
8 9 1 3 Perma 4 S 07/06
8 10 1 4 Curtis 4 B 07/07
9 9 1 1 Mir 4 B 07/09
9 13 1 7 Dougherty 4 S 06/27
9 10 1 8 Hakar 2 B 07/09
9 15 1 5 Duelberg 1 B 07/09
10 10 1 8 Jadin S B 07/09
10 11 1 3 Pablo 8 B 07/04
10 11 1 5 Murphy 4 B 07/01
10 12 1 6 Calvin 5 B 06/23
10 13 1 N Johnson 2 B 06/02
11 11 1 1 Mir 4 B 07/09
11 12 1 2 Russo 2 B 07/03
12 13 1 3 Block 4 S 07/09
12 13 1 4 Qui 4 B 06/21
12 12 1 5 Block 4 S 07/09
13 14 1 2 Duval 4 B 07/17
13 15 1 5 Miller 4 S 07/13
13 14 1 8 Maufrais 4 B 07/03
14 15 1 1 Baca 4 B 07/04
14 15 1 3 Romero 8 B 07/02
14 15 1 4 Robertson 3 B 07/04
14 15 1 6 Sturrock 12 B 07/08
14 14 1 7 Poole 4 S 07/13
14 15 1 N Contreras 4 B 06/12
15 16 1 2 Larson 3 B 06/20
15 16 1 7 Sue? 4 S 07/15
15 17 1 8 Hall 2 B 06/19
16 18 1 4 Garcia 4 B 06/02
16 17 1 5 Macarthy 4 D 07/11
16 17 1 6 Block 4 S 06/21
"""
  @july19a = """
1 1 1 3 Contractor 4 S 06/28
1 4 1 4 x          4 S 06/21
1 3 1 5 Name?      4 S 06/28
1 2 1 7 Woods      4 S 06/29
1 2 1 8 Rana       4 B 06/29
1 3 1 N Diachuk    2 B 06/03
2 4 1 3 Markottor  8 B 06/29
2 4 1 6 Fiffen     4 S 06/29
3 6 1 1 Who        4 S 07/06
3 7 1 7 Bonnel     1 B 06/09
3 5 1 8 Block      4 S 06/29
3 6 1 S Kile       4 B 06/06
4 5 1 S Carrera    4 B 06/28
4 6 1 N Feldewert  2 B 06/22
5 7 1 4 Costilo    4 S 06/27
5 8 1 6 Kroger    12 B 06/02
7 11 1 2 Shinn     3 B 06/21
7 9  1 5 Brent     4 S 07/06
7 8  1 8 Preiss    2 B 06/21
7 9  1 N Chitty    2 B 06/23
7 8  1 S South     2 B 06/20
8 9  1 3 Perma     4 S 07/06
8 10 1 4 Curtis    4 B 07/07
9 9  1 1 Mir       4 B 07/09
9 13 1 7 Dougherty 4 S 06/27
9 10  1 8 Hakar    2 B 07/09
9 15  1 5 Duelberg 1 B 07/09
10 10 1 8 Jadin    S B 07/09
10 11 1 3 Pablo    8 B 07/04
10 11 1 5 Murphy   4 B 07/01
10 12 1 6 Calvin   5 B 06/23
10 13 1 N Johnson  2 B 06/02
11 11 1 1 Mir      4 B 07/09
11 12 1 2 Russo    2 B 07/03
12 13 1 3 Block    4 S 07/09
12 13 1 4 Qui      4 B 06/21
12 12 1 5 Block    4 S 07/09
13 14 1 2 Duval    4 B  07/17
13 15 1 5 Miller   4 S  07/13
13 14 1 8 Maufrais 4 B  07/03
14 15 1 1 Baca     4 B  07/04
14 15 1 3 Romero   8 B  07/02
14 15 1 4 Robertson 3 B 07/04
14 15 1 6 Sturrock 12 B 07/08
14 14 1 7 Poole     4 S 07/13
14 15 1 N Contreras 4 B 06/12
15 16 1 2 Larson    3 B 06/20
15 16 1 7 Sue?      4 S 07/15
15 17 1 8 Hall      2 B 06/19
16 18 1 4 Garcia    4 B 06/02
16 17 1 5 Macarthy  4 D 07/11
16 17 1 6 Block     4 S 06/21
"""

  @july20 = """
6/29 7/6 2 Pachner 4 B 6/05 $185
6/30 7/2 5 Hota    4 B 6/01 $155
1 1 3 Contractor 4 S 6/1 279
1 4 4 x          4 S 6/21 275
1 3 5 Name?      4 S 6/28 195
1 2 7 Woods      4 S 6/29 175
1 2 8 Rana       4 B 6/29 120
1 3 N Diachuk    2 B 6/3  165
2 4 3 Markottor  8 B 6/29 315
2 4 6 Fiffen     4 S 6/29 300
3 6 1 Who        4 S 7/6  145
3 7 7 Bonnel     1 B 6/9  175
3 5 8 Block  4
3 6 S Kile  4
4 5 S Carrera 4
4 6 N Feldewert 2
5 7 4 Costilo 4
5 8 6 Kroger 12
7 11 2 Shinn 3
7 9  5 Brent  4
7 8  8 Preiss 2
7 9  N Chitty 2
7 8  S South  2
8 9  3 Perma  4
8 10 4 Curtis 4
9 9  1 Mir 4
9 13  7 Dougherty
9 10  8 Hakar 2
9 15  5 Duelberg 1
10 10 8 Jadin
10 11 3 Pablo 8
10 11 5 Murphy 4
10 12 6 Calvin 5
10 13 N Johnson 2
11 11 1 Mir  4
11 12 2 Russo 2
12 13 3 Block 4
12 13 4 Qui  4
12 12 5 Block 4
13 14 2 Duval 4
13 15 5 Miller 4
13 14 8 Maufrais 4
14 15 1 Baca 4
14 15 3 Romero 8
14 15 4 Roberttson 3
14 15 6 Sturrock 12
14 14 7 Poole
14 15 N Contreras
15 16 2 Larson 3
15 16 7 Sue?
15 17 8 Hall 2
16 18 4 Garcia 4
16 17 5 Mcarthy 4
16 17 6 Block  4
"""

  @july = """
07/31 08/03 4 S Krupa 3 Booking 06/30 $155 $620 $65.41 $685.41
07/30 08/04 6 8 Young 4 Booking 06/08 $120 $720 $75.96 $795.96
07/29 07/30 2 4 Alton 2 Skyline 07/09 $125 $250 $26.38 $276.38
07/28 07/29 2 2 ??? 4 Skyline 07/18 $185 $370 $39.03 $409.03
07/28 07/29 2 7 Ramos 2 Booking 07/09 $165 $330 $34.81 $364.81
07/28 07/29 2 8 Bardallis 3 Booking 06/26 $120 $240 $25.32 $265.32
07/28 07/29 2 S Ravel 4 Booking 06/28 $155 $310 $32.70 $342.70
07/27 07/27 1 2 Bl 4 Skyline 07/18 $185 $185 $19.52 $204.52
07/27 07/28 2 4 Schreiner 4 Booking 07/17 $145 $290 $30.59 $320.59
07/27 07/27 1 8 Bl 4 Skyline 07/18 $120 $120 $12.66 $132.66
07/26 07/29 4 1 Shriver 4 Booking 07/09 $145 $580 $61.19 $641.19
07/26 07/29 4 3 Miller 4 Skyline 07/01 $275 $1100 $116.05 $1216.05
07/26 07/29 4 5 Miller 4 Skyline 07/01 $195 $780 $82.29 $862.29
07/26 07/29 4 6 Miller 4 Skyline 07/01 $300 $1200 $126.60 $1326.60
07/26 07/29 4 N Shriver 4 Booking 06/29 $165 $660 $69.63 $729.63
07/26 07/27 2 S Richardson 4 Booking 06/07 $155 $310 $32.70 $342.70
07/25 07/26 2 4 Steiner 3 Booking 06/20 $145 $290 $30.59 $320.59
07/24 07/25 2 1 huls 2 Booking 07/09 $125 $250 $26.38 $276.38
07/24 07/26 3 2 Constantine 3 Booking 06/27 $185 $555 $58.55 $613.55
07/24 07/25 2 5 Davis 3 Booking 07/13 $195 $390 $41.14 $431.14
07/24 07/25 2 N huls 2 Booking 06/11 $165 $330 $34.81 $364.81
07/23 07/25 3 6 Narasimhan 10 Booking 06/05 $315 $945 $99.70 $1044.70
07/23 07/26 4 8 Mann 4 Booking 06/08 $120 $480 $50.64 $530.64
07/22 07/23 2 5 stone 2 Booking 07/03 $195 $390 $41.14 $431.14
07/22 07/27 6 7 Masom 4 Skyline 07/09 $175 $1050 $110.77 $1160.77
07/21 07/23 3 1 Henderson 4 Booking 07/09 $145 $435 $45.89 $480.89
07/21 07/22 2 2 wills 4 Booking 07/01 $185 $370 $39.03 $409.03
07/21 07/22 2 3 Keleher 8 Booking 06/07 $315 $630 $66.47 $696.47
07/21 07/22 2 4 Sterup 2 Booking 06/01 $145 $290 $30.59 $320.59
07/21 07/22 2 8 Micheal 2 Booking 06/17 $120 $240 $25.32 $265.32
07/21 07/23 3 N Henderson 4 Booking 06/27 $165 $495 $52.22 $547.22
07/21 07/24 4 S Broten 4 Booking 06/25 $155 $620 $65.41 $685.41
07/20 07/21 2 5 Geiker 4 Skyline 06/29 $195 $390 $41.14 $431.14
07/20 07/21 2 6 Villanueva 12 Booking 06/03 $315 $630 $66.47 $696.47
07/18 07/19 2 1 Copper 4 Skyline 07/11 $145 $290 $30.59 $320.59
07/17 07/19 3 2 Frank 2 Booking 07/08 $185 $555 $58.55 $613.55
07/17 07/20 4 S Wilkins 4 Booking 06/15 $155 $620 $65.41 $685.41
07/16 07/19 4 N Becker 4 Booking 07/03 $165 $660 $69.63 $729.63
"""
  @aug = """
08/31 08/31 1 3 Jenkine 4 Skyline 06/27 $275 $275 $29.01 $304.01
08/22 08/26 5 8 Nichols 2 Booking 07/18 $98 $490 $51.70 $541.70
08/20 08/20 1 6 Brenner 4 Skyline 06/27 $300 $300 $31.65 $331.65
08/18 08/19 2 2 Mitchell 4 Booking 06/30 $185 $370 $39.03 $409.03
08/18 08/19 2 8 Bryant 4 Booking 07/06 $120 $240 $25.32 $265.32
08/16 08/19 4 S Howell 4 Skyline 07/18 $155 $620 $65.41 $685.41
08/14 08/18 5 6 Jones 2 Skyline 07/09 $235 $1175 $123.96 $1298.96
08/14 08/15 2 8 Leech 4 Booking 06/07 $130 $260 $27.43 $287.43
08/14 08/16 3 N TAK 2 Booking 07/09 $145 $435 $45.89 $480.89
08/13 08/14 2 2 Sanders 2 Skyline 07/10 $165 $330 $34.81 $364.81
08/13 08/19 7 7 Maris 4 Skyline 06/27 $175 $1225 $129.24 $1354.24
08/12 08/12 1 1 Sanders 2 Booking 07/10 $125 $125 $13.19 $138.19
08/12 08/15 4 4 Settle 2 Booking 07/18 $125 $500 $52.75 $552.75
08/12 08/15 4 5 settle 2 Booking 07/09 $195 $780 $82.29 $862.29
08/11 08/11 1 1 Colbert 4 Skyline 07/16 $145 $145 $15.30 $160.30
08/11 08/11 1 4 Colbert 4 Skyline 07/16 $145 $145 $15.30 $160.30
08/11 08/12 2 6 Jones 10 Booking 07/15 $360 $720 $75.96 $795.96
08/11 08/12 2 7 Mischer 1 Booking 07/16 $165 $330 $34.81 $364.81
08/10 08/14 5 3 Yeaman 4 Skyline 07/18 $275 $1375 $145.06 $1520.06
08/10 08/12 3 8 Clark 4 Booking 06/06 $130 $390 $41.14 $431.14
08/10 08/13 4 S Burns 2 Booking 07/07 $155 $620 $65.41 $685.41
08/09 08/10 2 5 Casali 6 Skyline 07/10 $215 $430 $45.37 $475.37
08/09 08/10 2 6 Casali 16 Booking 06/30 $445 $890 $93.89 $983.89
08/08 08/12 5 2 Dasarakotohpa 4 Skyline 07/09 $185 $925 $97.59 $1022.59
08/08 08/12 5 N Chavez 4 Booking 07/14 $165 $825 $87.04 $912.04
08/07 08/10 4 1 Dusterbeck 4 Skyline 07/09 $145 $580 $61.19 $641.19
08/07 08/08 2 8 Bates 2 Booking 07/18 $98 $196 $20.68 $216.68
08/06 08/07 2 4 MacDowell 4 Skyline 07/18 $145 $290 $30.59 $320.59
08/06 08/08 3 5 Lansome 4 Skyline 07/16 $195 $585 $61.72 $646.72
08/05 08/08 4 6 Pham 4 Booking 07/11 $300 $1200 $126.60 $1326.60
08/05 08/06 2 8 Edwards 4 Skyline 07/09 $120 $240 $25.32 $265.32
08/04 08/05 2 1 Gagon 4 Skyline 07/09 $145 $290 $30.59 $320.59
08/04 08/05 2 3 Hedgecock 8 Booking 06/24 $315 $630 $66.47 $696.47
08/04 08/05 2 4 Hagen 2 Booking 06/29 $145 $290 $30.59 $320.59
08/04 08/05 2 7 Hagen 2 Booking 07/09 $165 $330 $34.81 $364.81
08/04 08/06 3 N Zink 4 Booking 06/30 $165 $495 $52.22 $547.22
08/04 08/04 1 S Vink? 4 Skyline 07/18 $155 $155 $16.35 $171.35
08/03 08/04 2 2 Glynn 3 Booking 07/07 $185 $370 $39.03 $409.03
08/03 08/04 2 6 bieber 12 Booking 07/05 $300 $600 $63.30 $663.30
08/02 08/02 1 4 Stewart 4 Skyline 07/09 $145 $145 $15.30 $160.30
08/01 08/03 3 3 Jenkine 4 Skyline 07/09 $275 $825 $87.04 $912.04
08/01 08/04 4 5 Vinkevicius 4 Booking 07/12 $195 $780 $82.29 $862.29
08/01 08/02 2 6 YEAGER 12 Booking 06/22 $315 $630 $66.47 $696.47
08/01 08/02 2 N Oliver 4 Booking 07/11 $165 $330 $34.81 $364.81
07/31 08/03 4 S Krupa 3 Booking 06/30 $155 $620 $65.41 $685.41
07/30 08/04 6 8 Young 4 Booking 06/08 $120 $720 $75.96 $795.96
"""

  @sept = """
09/01 09/03 3 1 Kelller 4 Skyline 07/11 $145 $435 $45.89 $480.89
09/01 09/03 3 4 Keller 4 Skyline 07/11 $145 $435 $45.89 $480.89
09/01 09/03 3 6 b 4 Skyline 06/21 $300 $900 $94.95 $994.95
09/01 09/03 3 8 Seacreas 4 Booking 07/03 $120 $360 $37.98 $397.98
09/02 09/03 2 N Husbands 4 Booking 07/05 $165 $330 $34.81 $364.81
09/02 09/03 2 S Retana 2 Booking 07/02 $155 $310 $32.70 $342.70
09/07 09/12 6 3 Cunningham 3 Booking 06/13 $1 $1 $0.11 $1.11
09/07 09/08 2 4 Wight 4 Booking 06/13 $145 $290 $30.59 $320.59
09/07 09/09 3 6 Andrus 4 Skyline 07/11 $300 $900 $94.95 $994.95
09/07 09/09 3 N Fleming 2 Booking 06/30 $165 $495 $52.22 $547.22
09/08 09/09 2 1 Featherstun 1 Booking 06/02 $145 $290 $30.59 $320.59
09/08 09/09 2 8 Hajek 2 Booking 06/12 $120 $240 $25.32 $265.32
09/08 09/09 2 S Dreiling 1 Booking 06/15 $155 $310 $32.70 $342.70
09/09 09/10 2 2 Rhodes 4 Booking 07/16 $185 $370 $39.03 $409.03
09/14 09/17 4 6 Jame 8 Skyline 07/16 $340 $1360 $143.48 $1503.48
09/15 09/16 2 8 Smith 4 Booking 07/15 $120 $240 $25.32 $265.32
"""

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


