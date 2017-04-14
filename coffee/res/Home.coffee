
$ = require( 'jquery' )

class Home

  module.exports = Home

  constructor:( @stream, @store, @room, @pict ) ->
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs

  ready:( book ) ->
    @book = book
    $('#MakeRes').click( @onMakeRes )
    $('#HomeBtn').click( @onHome )
    $('#MapDirs').click( () => Util.toPage('rooms/X.html') )
    $('#Contact').click( () => Util.toPage('rooms/Y.html') )
    $('#Head').append( @headHtml() )
    @listRooms()
    @pict.createSlideShow('M', 600, 600 )
    return

  headHtml:() ->
    """
    <ul class="Head1">
     <li>Trout Fishing</li>
     <li>Bring your Pet</li>
    </ul>
    <ul class="Head2">
      <li>Near YMCA</li>
      <li>Hiking</li>
    </ul>
    <ul class="Head3">
      <li>Free Parking</li>
      <li>3 Private Spas</li>
    </ul>
    <ul class="Head4">
      <li>WiFi in Cabins 1-8</li>
      <li>All Non-Smoking Cabins</li>
    </ul>
    """

  listRooms:() ->
    $('#Slides').css( { left:"22%", width:"78%" })
    htm  = """<div class="HomeSee">Enjoy Everything Skyline Has to Offer</div>"""
    htm += """<div class="RoomSee">See Our Cottages</div>"""
    htm += """<ul  class="RoomUL">"""
    for own roomId, room of @rooms
      htm += """<li class="RoomLI"><a href="rooms/#{roomId}.html">#{room.name}</a></li>"""
    htm += """</ul>"""
    $("#View").append( htm )
    return

  hideMkt:() ->
    $('#MakeRes').hide()
    $('#HomeBtn').hide()
    $('#MapDirs').hide()
    $('#Contact').hide()
    $('#Caption').hide()
    $('#Head'   ).hide()
    $('#View'   ).hide()

  showMkt:() ->
    $('#MakeRes').show()
    $('#HomeBtn').hide()
    $('#MapDirs').show()
    $('#Contact').show()
    $('#Caption').show()
    $('#Head'   ).show()
    $('#View'   ).show()

  showConfirm:() ->
    $('#MakeRes').hide()
    $('#HomeBtn').show()
    $('#MapDirs').show()
    $('#Contact').show()
    $('#Caption').hide()
    $('#Head'   ).hide()
    $('#View'   ).hide()

  onMakeRes:() =>
    @hideMkt()
    @book.ready()
    return

  onHome:() =>
    @showMkt()
    return