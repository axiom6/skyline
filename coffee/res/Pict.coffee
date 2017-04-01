


if Util.isCommonJS
  $   = require( 'jquery'        )
else
  Util.loadScript "../../node_module/jquery/dist/jquery.js", () ->
    Img = $.getJSON( "../../data/Img.json" )

class Pict

  module.exports = Pict
  window.Pict    = Pict

  @page:( title, prev, curr, next ) ->
    pict = new Pict()
    Util.ready () ->
      pict.roomPageHtml( title, prev, next )
      pict.createSlideShow( curr, 600, 400 )
    return

  constructor:() ->

  roomPageHtml:( title, prev, next ) ->
    prevPage = """ '#{prev}.html' """
    nextPage = """ '#{next}.html' """
    htm = """
        <button class="prev" onclick="Util.toPage(#{prevPage});"   >Prev Room</button>
        <span   class="room">#{title}</span>
        <button class="next" onclick="Util.toPage(#{nextPage});"   >Next Room</button>
        <button class="home" onclick="Util.toPage('../index.html');">Home Page</button>
    """
    $('#top').append( htm )
    return

  createSlideShow:( roomId, w,  h ) ->
    $('#Slides').append( @wrapperHtml() )
    htm = ""
    Img = if roomId is 'M' then require( 'data/Img.json' ) else require( '../../data/Img.json' )
    dir = Img[roomId].dir
    for pic in Img[roomId].pics
      htm += @li( pic, dir )
    $('#slideshow').append( htm )
    @initTINY( w, h )
    return

  li:( pic, dir ) ->
    """<li><h3>#{pic.name}</h3><span>#{dir}#{pic.src}</span><p>#{pic.p}</p><a href="#"><img src="#{dir}#{pic.src}" width="100" height="70" alt="#{pic.name}"/></a></li>"""

  wrapperHtml:() ->
    """
    <ul id="slideshow"></ul>
    <div id="wrapper">
      <div id="fullsize">
        <div id="imgprev" class="imgnav" title="Previous Image"></div>
        <div id="imglink"></div>
        <div id="imgnext" class="imgnav" title="Next Image"></div>
        <div id="image"></div>
        <div id="information">
          <h3></h3>
          <p></p>
        </div>
      </div>
      <div id="thumbnails">
        <div id="slideleft" title="Slide Left"></div>
        <div id="slidearea">
          <div id="slider"></div>
        </div>
        <div id="slideright" title="Slide Right"></div>
      </div>
    </div>
    """

  initTINY:( w, h ) ->
    TINY.ElemById('slideshow').style.display='none'
    TINY.ElemById('wrapper'  ).style.display='block'
    window.slideshow=new TINY.slideshow("slideshow")
    slideshow = window.slideshow
    slideshow.auto=true
    slideshow.speed=5
    slideshow.link="linkhover"
    slideshow.info="information"
    slideshow.thumbs="slider"
    slideshow.left="slideleft"
    slideshow.right="slideright"
    slideshow.scrollSpeed=4
    slideshow.spacing=5
    slideshow.active="#fff"
    @resizeSlideView( w, h )
    slideshow.init("slideshow","image","imgprev","imgnext","imglink")

  resizeSlideView:( w, h ) ->
    $('#wrapper'  ).css( { width:w,     height:h       } )
    $('#fullsize' ).css( { width:w,     height:h-100   } )
    $('#slidearea').css( { width:w- 44, height:61      } )
    $('#image img').css( { width:w-100, height:h*0.666 } )
    slideshow.width  = w-100
    slideshow.height = h*0.666
    return

