
$     = require( 'jquery' )

class Home

  module.exports = Home

  constructor:( @stream, @store, @room, @pict ) ->
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs

  ready:( book ) ->
    @book = book
    $('#MakeRes'   ).click(  @onMakeRes )
    @listRooms()
    @pict.createSlideShow('M', 600, 600 )
    return

  listRooms:() ->
    $('#Slides').css( { left:"20%", width:"80%" })
    htm = """<ul class="RoomUL">"""
    for own roomId, room of @rooms
      htm += """<li class="RoomLI"><a href="rooms/#{roomId}.html">#{room.name}</a></li>"""
    htm += """</ul>"""
    $("#Viewer").append( htm )
    return

  onMakeRes:() =>
    $('#Viewer').hide()
    @book.ready()
    return