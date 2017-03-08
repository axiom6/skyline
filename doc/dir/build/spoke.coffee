
class Spoke

  @pdfCSS:( href ) ->
    return if not window.location.search.match(/pdf/gi)
    link      = document.createElement('link')
    link.rel  = 'stylesheet'
    link.type = 'text/css'
    link.href =  href
    document.getElementsByTagName('head')[0].appendChild link
    return

  @center:( selector ) ->
    elems = document.querySelectorAll( selector )
    for elem in elems
      flag = elem.getAttribute('data-center')
      continue if flag? and flag is 'none'
      horz = document.createElement("div")
      vert = document.createElement("div")
      horz.className = 'bespoke-horz'
      vert.className = 'bespoke-vert'
      for child in elem.childNodes
        vert.appendChild( child.cloneNode(true) )
      while elem.hasChildNodes()
        elem.removeChild( elem.lastChild )
      elem.appendChild( horz )
      horz.appendChild( vert )
    return
