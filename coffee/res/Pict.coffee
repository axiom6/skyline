
$     = require( 'jquery'       )

Img   = require(  'data/Img.json'  )


class Pict

  module.exports = Pict

  constructor:() ->

  li:( pic, dir ) ->
    """<li><h3>#{pic.name}</h3><span>#{dir}#{pic.src}</span><p>#{pic.p}</p><a href="#"><img src="#{pic.src}, width="100" alt="#{pic.name}"/></a></li>"""