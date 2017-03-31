
$     = require( 'jquery'       )

Img   = require(  'data/Img.json'  )


class Pict

  module.exports = Pict

  constructor:( @stream, @store, @room, @Data ) ->

  createSlideShow:( roomId ) ->
    htm = ""
    dir = Img[roomId].dir
    for pic in Img[roomId].pics
      Util.log("Pict.createSlideShow()", pic )
      htm += @li( pic, dir )
    $('#slideshow').append( htm )
    return

  li:( pic, dir ) ->
    """<li><h3>#{pic.name}</h3><span>#{dir}#{pic.src}</span><p>#{pic.p}</p><a href="#"><img src="#{dir}#{pic.src}", width="100" alt="#{pic.name}"/></a></li>"""