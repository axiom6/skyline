
$     = require( 'jquery' )

class Home

  module.exports = Home

  constructor:( @stream, @store, @room, @pict ) ->
    @rooms       = @room.rooms
    @roomUIs     = @room.roomUIs

  ready:( book ) ->
    @book = book
    $('#MakeRes'   ).click(  @onMakeRes )
    @pict.createSlideShow('M', 600, 600 )

  onMakeRes:() =>
    $('#Viewer').hide()
    @book.ready()