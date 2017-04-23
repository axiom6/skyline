

$ = require('jquery')

class Pict

  module.exports = Pict if module? and module.exports?
  window.Pict    = Pict

  @page:( title, prev, curr, next ) ->
    pict = new Pict()
    Util.ready () ->
      pict.roomPageHtml( title, prev, next )
      pict.createSlideShow( curr, 600, 600 )
      return
    return

  constructor:() ->

  roomPageHtml:( title, prev, next ) ->
    prevPage = """ '#{prev}.html' """
    nextPage = """ '#{next}.html' """
    htm = """
        <button class="prev" onclick="Util.toPage(#{prevPage});"    >Prev Room</button>
        <span   class="room">#{title}</span>
        <button class="next" onclick="Util.toPage(#{nextPage});"    >Next Room</button>
        <button class="home" onclick="Util.toPage('../index.html');">Home Page</button>
    """
    $('#top').append( htm )
    return

  createSlideShow:( roomId, w,  h ) ->
    $('#Slides').append( @wrapperHtml() )
    images = (Img) =>
      htm = ""
      dir = Img[roomId].dir
      for pic in Img[roomId].pics
        htm += @li( pic, dir )
      $('#slideshow').append( htm )
      @initTINY( w, h )
    url = if roomId is 'M' then "../data/Img.json" else "../../data/Img.json"
    $.getJSON( url, images )
    return

  li:( pic, dir ) ->
    """<li><h3>#{pic.name}</h3><span>#{dir}#{pic.src}</span><p>#{pic.p}</p><a href="#"><img src="#{dir}#{pic.src}" width="100" height="70" alt="#{pic.name}"/></a></li>"""

  viewVideo:( src ) =>
    Util.log('Pict.viewVideo()', src )
    $('#Slides' ).hide()
    $('#Video'  ).attr('src', src )
    $('#ViewVid').show()
    return

  # https://www.youtube.com/watch?v=MsUfGee7kYY
  # https://www.youtube.com/embed?v=MsUfGee7kYY
  onVideo:( e ) =>
    Util.log('Pict.onVideo()' )
    Util.noop( e )
    #viewVideo(        "//www.youtube.com/embed/MsUfGee7kYY")
    @viewVideo( "https://www.youtube.com/embed?v=MsUfGee7kYY")
    $('#VideoSee').text('View Slides').click( @onSlides )
    return

  onSlides:( e ) =>
    Util.log('Pict.onSlides()' )
    Util.noop( e )
    $('#ViewVid' ).hide()
    $('#Slides'  ).show()
    $('#VideoSee').text('View Video').click( @onVideo )
    return

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
    # @resizeSlideView( w, h ) # Holding off for now. Let slide.less do the work
    slideshow.init("slideshow","image","imgprev","imgnext","imglink")

  resizeSlideView:( w, h ) ->
    $('#wrapper'  ).css( { width:w,     height:h       } )
    $('#fullsize' ).css( { width:w,     height:h-100   } )
    $('#slidearea').css( { width:w- 45, height:61      } )
    $('#image'    ).css( { width:w-100, height:h-200 } )
    $('#image img').css( { width:w-100, height:h-200 } )
    slideshow.width  = w-100
    slideshow.height = h-200
    return

