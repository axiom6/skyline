
$          = require('jquery')
pivottable = require( 'pivottable' )
Store      = require( 'js/store/Store' )

class Pivot

  module.exports = Pivot  # Util.Export( Pivot, 'store/Pivot' )
  Store.Pivot    = Pivot

  constructor:( @stream, @store ) ->

  select:( table, where, htmlId  ) ->
    subject = @store.toSubject( table, 'select' )
    @stream.subscribe( subject, (objects) =>
      array = Util.toArray( objects )
      @show( array, htmlId ) )
    @store.select( table, where )
    return

  show:( array, htmlId="output" ) ->
    $( '#'+htmlId ).pivotUI( array )
    return


  showPractices:( practices, htmlId="output" ) ->
    $( '#'+htmlId ).pivotUI( practices, sorters: (attr) ->
      switch attr
        when 'plane'  then Pivot.$.pivotUtilities.sortAs( [ "Information", "DataScience", "Knowledge", "Wisdow" ] )
        when 'row'    then Pivot.$.pivotUtilities.sortAs( [ "Learn",   "Do",       "Share"     ] )
        when 'column' then Pivot.$.pivotUtilities.sortAs( [ "Embrace", "Innovate", "Encourage" ] )
        else null )
    return