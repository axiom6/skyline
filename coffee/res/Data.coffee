
class Data

  module.exports    = Data

  constructor:( @stream, @store, @room, @cust, @book ) ->

  initAllTables:() ->
    return

  dropAllTables:() ->
    return

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

