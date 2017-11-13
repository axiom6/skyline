
$ = Util.requireModule( 'jquery', 'skyline' )

class Pict

  window.Pict = Pict

  #console.log( window )

  @page:( title, prev, curr, next ) ->
    pict = new Pict()
    Util.ready () ->
      pict.roomPageHtml( title, prev, next )
      pict.createSlideShow( 'RoomSlides', curr )
      return
    return

  constructor:() ->
    @slide = null

  roomPageHtml:( title, prev, next ) ->
    prevPage = """ '#{prev}.html' """
    nextPage = """ '#{next}.html' """
    htm = """
        <button class="home" onclick="Util.toPage('../guest.html');">Home Page</button>
        <button class="prev" onclick="Util.toPage(#{prevPage});"    >Prev Cabin</button>
        <span   class="room">#{title}</span>
        <button class="next" onclick="Util.toPage(#{nextPage});"    >Next Cabin</button>
    """
    $('#top').append( htm )
    return

  createSlideShow:( parentId, roomId ) ->
    $par = $('#'+parentId)
    w    = $par.width()
    h    = $par.height()
    Util.log( 'Pict.createSlideShow()', { w:w, h:h } )
    $par.empty()
    $par.append( @wrapperHtml() )
    images = (Img) =>
      htm = ""
      dir = Img[roomId].dir
      for pic in Img[roomId]['pics']
        htm += @li( pic, dir )
      $('#slideshow').append( htm )
      @initTINY( w, h )
    url = if parentId is 'RoomSlides' then '../img/img.json'  else 'img/img.json'
    $.getJSON( url, images )
    return

  li:( pic, dir ) ->
    """<li><h3>#{pic.name}</h3><span>#{dir}#{pic.src}</span><p>#{pic.p}</p><a href="#"><img src="#{dir}#{pic.src}" width="100" height="70" alt="#{pic.name}"/></a></li>"""

  createFoto:( parentId, roomId ) ->
    $par = $('#'+parentId)
    w    = $par.width()
    h    = $par.height()
    $par.empty()
    images = (Img) =>
      htm = """<div id="slideshow" class="fotorama"  data-allowfullscreen="true">""" # data-nav="thumbs"
      dir = Img[roomId].dir
      for pic in Img[roomId]['pics']
        htm += @fotoImg( pic, dir, w, h )
      htm += """</div>"""
      $par.append( htm )
      $("#slideshow").fotorama()
    url = if parentId is 'RoomSlides' then '../img/img.json'  else 'img/img.json'
    $.getJSON( url, images )
    return

  fotoImg:( pic, dir, w, h ) ->
    #style = "max-width:100%; height:auto;"
    img  = """<img src="#{dir}#{pic.src}" data-width="#{w}" data-ratio="#{w/h}" data-maxwidth="100%" data-maxheight="100%" """
    img += """data-caption="#{pic.name}" """ if Util.isStr( pic.name )
    img += """>"""
    img

  onVideo:() =>
    window.slideshow.auto=false
    $('#Slides'   ).hide()
    $('#VideoView').show()
    $('#ViewVid'  ).show()
    $('#VideoSee' ).text('View Slides').click( @onSlides )
    return

  onSlides:(  ) =>
    $('#ViewVid' ).hide()
    $('#Slides'  ).show()
    window.slideshow.auto=true
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

  resizeSlideView:( w, h ) ->
    $('#wrapper'    ).css( { width:w,     height:h     } )
    $('#fullsize'   ).css( { width:w,     height:h-100 } )
    $('#slidearea'  ).css( { width:w- 45, height:61    } )
    $('#information').css( { width:w,     height:0     } )
    $('#image'      ).css( { width:w-100, height:h-200 } )
    $('#image > img').css( { width:w-100, height:h-200 } )
    $('#imglink'    ).css( { width:w-100, height:h-200 } )
    $('.imgnav'     ).css( { width:w-100, height:h-200 } )
    window.slideshow.width  = w-100
    window.slideshow.height = h-200
    return

  initTINY:( w, h ) ->
    TINY.ElemById('slideshow').style.display='none'
    TINY.ElemById('wrapper'  ).style.display='block'
    window.slideshow =  new TINY.slideshow("slideshow")
    slideshow = window.slideshow
    slideshow.auto=false #true
    slideshow.speed=10
    slideshow.link="linkhover"
    slideshow.info="information"
    slideshow.thumbs="slider"
    slideshow.left="slideleft"
    slideshow.right="slideright"
    slideshow.scrollSpeed=4
    slideshow.spacing=5
    slideshow.active="#fff"
    slideshow.init("slideshow","image","imgprev","imgnext","imglink")
    @resizeSlideView( w, h ) # Holding off for now. Let slide.less do the work
    return

  initSlide:( w, h ) ->
    slide = new Slide("slideshow")
    Slide.ElemById('slideshow').style.display='none'
    Slide.ElemById('wrapper'  ).style.display='block'
    slide.auto=false #true
    slide.speed=10
    slide.link="linkhover"
    slide.info="information"
    slide.thumbs="slider"
    slide.left="slideleft"
    slide.right="slideright"
    slide.scrollSpeed=4
    slide.spacing=5
    slide.active="#fff"
    @resizeSlideView( w, h ) # Holding off for now. Let slide.less do the work
    slide.init("slide","image","imgprev","imgnext","imglink")
    slide
