
$     = require( 'jquery' )

class Home

  module.exports = Home

  constructor:( @stream, @store, @room, @pict ) ->
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs

  ready:( book ) ->
    @book = book
    $('#MakeRes').click( @onMakeRes )
    $('#MapDirs').click( () => Util.toPage('rooms/X.html') )
    $('#Contact').click( () => Util.toPage('rooms/Y.html') )

    @listRooms()
    @pict.createSlideShow('M', 600, 600 )
    return

  listRooms:() ->
    $('#Slides').css( { left:"20%", width:"80%" })
    htm  = """<div class="HomeSee">Enjoy Everything Skyline has to Offer</div>"""
    htm += """<div class="RoomSee">See Our Cottages</div>"""
    htm += """<ul  class="RoomUL">"""
    for own roomId, room of @rooms
      htm += """<li class="RoomLI"><a href="rooms/#{roomId}.html">#{room.name}</a></li>"""
    htm += """</ul>"""
    $("#Viewer").append( htm )
    return

  onMakeRes:() =>
    $('#Viewer').hide()
    @book.ready()
    return