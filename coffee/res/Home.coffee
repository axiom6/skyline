
$    = require( 'jquery' )
Data = require( 'js/res/Data'   )
UI   = require( 'js/res/UI'     )

class Home

  module.exports = Home

  constructor:( @stream, @store, @res, @pict ) ->

  ready:( book ) ->
    @book = book
    $('#MakeRes').click( @onMakeRes )
    $('#HomeBtn').click( @onHome    )
    $('#MapDirs').click( () => Util.toPage('rooms/X.html') )
    $('#Contact').click( () => Util.toPage('rooms/Y.html') )
    $('#Head').append( @headHtml() )
    @viewHtml()

    @pict.createSlideShow( 'Slides',   'First',    600, 600 )

    $('#First').click( () => @pict.createSlideShow( 'Slides', 'First', 600, 600 ) )
    $('#Deck' ).click( () => @pict.createSlideShow( 'Slides', 'Deck',  600, 600 ) )
    $('#Mtn'  ).click( () => @pict.createSlideShow( 'Slides', 'Mtn',   600, 600 ) )
    $('#River').click( () => @pict.createSlideShow( 'Slides', 'River', 600, 600 ) )
    $('#Walk' ).click( () => @pict.createSlideShow( 'Slides', 'Walk',  600, 600 ) )
    $('#Wild' ).click( () => @pict.createSlideShow( 'Slides', 'Wild',  600, 600 ) )
    $('#Yard' ).click( () => @pict.createSlideShow( 'Slides', 'Yard',  600, 600 ) )

    $('#VideoSee').click( @pict.onVideo )
    return

  headHtml:() ->
    """
    <ul class="Head1">
     <li>Trout Fishing</li>
     <li>Bring your Pet</li>
     <li>Owner On Site</li>
    </ul>
    <ul class="Head2">
      <li>Hiking</li>
      <li>Free Wi-Fi</li>
      <li>Cable TV</li>
    </ul>
    <ul class="Head3">
      <li>Private Parking Spaces</li>
      <li>Kitchens in Every Cabin</li>
      <li>3 Private Spas</li>
    </ul>
    <ul class="Head4">
      <li>Private Barbecue Grills</li>
      <li>All Non-Smoking Cabins</li>
      <li>Wood Burning Fireplaces</li>
    </ul>
    """

  viewHtml:() ->
    $('#Slides').css( { left:"22%", width:"78%" })
    htm  = """<div class="HomeSee">Enjoy Everything Skyline Has to Offer</div>"""
    htm += @viewBtns()
    htm += """<div class="RoomSee">See Our Cabins</div>"""
    htm += """<div class="FootSee">Skyline Cottages Where the River Meets the Mountains</div>"""
    htm += """<ul  class="RoomUL">"""
    for own roomId, room of @res.rooms
      htm += """<li class="RoomLI"><a href="rooms/#{roomId}.html">#{room.name}</a></li>"""
    htm += """</ul>"""
    $("#View").append( htm )
    return

  viewBtns:() ->
    """<div id="ViewBtns">
         <span id="Video">Video</span>
         <span id="First">Overview</span>
         <span id="Deck" >Deck</span>
         <span id="Mtn"  >Mountains</span>
         <span id="River">River</span>
         <span id="Walk" >Walk</span>
         <span id="Wild" >Wildlife</span>
         <span id="Yard" >Yard</span>
       </div>
     """
    #$("#View").append("""<button id="VideoSee" class="btn btn-primary"">View Video</button>""")

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