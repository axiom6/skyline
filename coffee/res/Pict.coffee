
$ = Util.requireModule( 'jquery', 'skyline' )

class Pict

  window.Pict = Pict

  #console.log( window )

  @page:( title, prev, curr, next ) ->
    pict = new Pict()
    Util.ready () ->
      pict.roomPageHtml( title, prev, next )
      pict.createFoto( 'RoomSlides', curr )
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

  createFoto:( parentId, roomId ) ->
    $par  = $('#'+parentId)
    w     = Math.max( $par.width(),  640 )
    h     = Math.max( $par.height(), 640 )
    r     = if w > 40 and h > 40 then w/h else 1.0
    id    = if parentId is 'RoomSlides' then "slideroom" else "slideshow"
    #Util.log( 'Pict.createFoto()', { w:w, h:h, r:r } )
    $par.empty()
    images = (Img) =>
      htm  = """<div id="#{id}" class="fotorama"  data-allowfullscreen="true" """ # data-nav="thumbs"
      htm += """data-maxwidth="#{w}"   data-maxheight="#{h}"   data-ratio="#{r}" """
      htm += """data-minwidth="#{640}" data-minheight="#{640}" >"""
      dir = Img[roomId].dir
      for pic in Img[roomId]['pics']
        htm += @fotoImg( pic, dir )
      htm += """</div>"""
      $par.append( htm )
      $('#'+"#{id}").fotorama()
    url = if parentId is 'RoomSlides' then '../img/img.json'  else 'img/img.json'
    $.getJSON( url, images )
    return

  # data-width="#{w}"
  fotoImg:( pic, dir ) ->
    htm  = """<img src="#{dir}#{pic.src}"  """
    htm += """data-caption="#{pic.name}" """ if Util.isStr( pic.name )
    htm += """>"""
    htm

  createVid:( parentId ) ->
    $par  = $('#'+parentId)
    w     = Math.max( $par.width(),  640 )
    h     = Math.max( $par.height(), 640 )
    r     = if w > 40 and h > 40 then w/h else 1.0
    $par.empty()
    htm  = """<div id="slideshow" class="fotorama"  data-allowfullscreen="true" """
    htm += """data-maxwidth="#{w}"   data-maxheight="#{h}"   data-ratio="#{r}" """
    htm += """data-minwidth="#{640}" data-minheight="#{640}" >"""
    htm += """<a   src="https://www.youtube.com/embed/MsUfGee7kYY">Skyline Tour</a>"""
    htm += """</div>"""
    $par.append( htm )