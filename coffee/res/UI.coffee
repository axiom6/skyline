
$    = require( 'jquery'      )
Data = require( 'js/res/Data' )

class UI

  module.exports = UI

  @htmlSelect:( htmlId, array, choice, klass="", max=undefined ) ->
    style = if Util.isStr(klass) then klass else htmlId
    htm   = """<select name="#{htmlId}" id="#{htmlId}" class="#{style}">"""
    where = if max? then (elem) -> elem <= max else () -> true
    for elem in array when where(elem)
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  @htmlInput:( htmlId, value="", klass="", label="", type="text" ) ->
    style = if Util.isStr(klass) then klass else htmlId
    htm   = ""
    htm  += """<label for="#{htmlId}" class="#{style+'Label'}">#{label}</label>"""  if Util.isStr(label)
    htm  += """<input id= "#{htmlId}" class="#{style}" value="#{value}" type="#{type}">"""
    htm

  @htmlButton:( htmlId, klass, title ) ->
    """<button id="#{htmlId}" class="btn btn-primary #{klass}">#{title}</button>"""

  @htmlArrows:( htmlId, klass ) ->
    """<span id="#{htmlId}L">&#9664;</span>
       <span id="#{htmlId}" class="#{klass}"></span>
       <span id="#{htmlId}R">&#9654;</span>"""

  @onArrowsMMDD:( htmlId, onMMDD=null ) ->

    decMMDD = () ->
      $mmdd = $('#'+htmlId)
      mmdd0 = $mmdd.text()
      mmdd1 = Data.advanceMMDD(   mmdd0,  -1   )
      #Util.log( 'Input.decMMDD', mmdd0, mmdd1 )
      $mmdd.text( mmdd1 )
      if htmlId is 'NRArrive'
         onMMDD( mmdd1, 'Mine' ) if onMMDD?
      else
         onMMDD( mmdd0, 'Free' ) if onMMDD?
      return

    incMMDD = () ->
      $mmdd = $('#'+htmlId)
      mmdd0 = $mmdd.text()
      mmdd1 = Data.advanceMMDD(   mmdd0, 1     )
      #Util.log( 'Input.incMMDD', mmdd0, mmdd1 )
      $mmdd.text( mmdd1 )
      if htmlId is 'NRStayTo'
         onMMDD( mmdd1, 'Mine' ) if onMMDD?
      else
         onMMDD( mmdd0, 'Free' ) if onMMDD?
      return

    $('#'+htmlId+'L').click( decMMDD )
    $('#'+htmlId+'R').click( incMMDD )
    return

  # Sets htmlId property on obj
  @makeSelect:( htmlId, obj ) =>
    onSelect = (event) =>
      obj[htmlId] = event.target.value
      Util.log( htmlId, obj[htmlId] )
    $('#'+htmlId).change( onSelect )
    return

  # Sets htmlId property on obj
  @makeInput:( htmlId, obj ) =>
    onInput = (event) =>
      obj[htmlId] = event.target.value # $('#'+htmlId).val()
      Util.log( htmlId, obj[htmlId] )
    $('#'+htmlId).change( onInput )
    return

  # This is a hack for unreliable storage in jQuery.attr - found other formating error so not needed
  @attr:( $elem, name ) ->
    value = $elem.attr( name.toLowerCase() )
    Util.log( 'Res.attr one', name, value )
    value = if Util.isStr(value) and value.charAt(0) is ' ' then value.substr(1)     else value
    value = if Util.isStr(value) then Util.toCap(value) else value
    Util.log( 'Res.attr two', name, value )
    value

