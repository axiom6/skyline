

Store          = require( 'js/store/Store' )
Store.Firebase = require( 'firebase' )

class Firestore extends Store

  module.exports   = Firestore

  constructor:( stream, uri, @config ) ->
    super( stream, uri, 'Firestore' )
    @fb = @init( @config ) # @dbName set by Store in super constructor
    @anon() # Anonomous logins have to enabled
    @fd = Store.Firebase.database()

  init:( config ) ->
    Store.Firebase.initializeApp(config)
    Util.log( 'Firestore.init', config )
    Store.Firebase

  # OK
  add:( t, id, object  ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'add', object )
      else
        @onerror( tableName, id, 'add', object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )

  # OK
  get:( t, id ) ->
    tableName = @tableName(t)
    @fd.ref(tableName+'/'+id).once('value', (snapshot) =>
      if snapshot.val()?
        @publish( tableName, id, 'get', snapshot.val() )
      else
        @onerror( tableName, id, 'get', {}, { msg:'Firestore get error' } ) )

  # Same as add
  put:( t, id,  object ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'put', object )
      else
        @onerror( tableName, id, 'put', object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )

  # OK
  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'del', {} )
      else
        @onerror( tableName, id, 'del', {}, { error:error } )
    @fd.ref(tableName+'/'+id).remove( onComplete )

  # OK of set takes objects
  insert:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error } )
    @fd.ref(tableName).set( objects, onComplete )

  # OK if snapshot returns objects
  select:( t, where=Store.where ) ->
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        @publish( tableName, 'none', 'select', objects, { where:where.toString() } )
      else
        @onerror( tableName, 'none', 'select', objects, { where:where.toString() } )
    @fd.ref(tableName).once('value', onComplete )

  # Review - OK if update takes objects and onComplete
  update:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error } )
    @fd.ref(tableName).update( objects, onComplete )

  # Review - OK if this is really the right approach
  remove:( t, where=Store.where ) ->
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        for key, object of objects when where(val)
          @fb.ref(t).remove( key ) # Need to see if onComplete is needed
        @publish( tableName, 'none', 'remove', objects, { where:where.toString() } )
      else
        @onerror( tableName, 'none', 'remove', objects, { where:where.toString() } )
    @fd.ref(t).once('value', onComplete )

  # Supported? are tables just child nodes
  open:( t, schema={} ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'open', {}, { schema:schema } )
      else
        @onerror( tableName, 'none', 'open', {}, { schema:schema, error:error } )
    @fd.ref().push( tableName, onComplete )

  show:( t=undefined ) ->
    tableName = if t? then @tableName(t) else @dbName
    keys  = []
    onComplete = (snapshot) =>
      snapshot.forEach( (key) =>
        keys.push( key.key() )
        @publish( tableName, 'none', 'show', keys ) )
    if t?
      @fd.ref(tableName).once('value', onComplete )
    else
      @fd.ref(         ).once('value', onComplete )

  # Supported? Obscure
  make:( t, alters={} ) ->
    @onerror( t, 'none', 'make', {}, { error:'Store.make() not supported', alters:alters } )
    return

  # Supported?
  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'drop', "OK" )
      else
        @onerror( tableName, 'none', 'drop', {}, { error:error } )
    @fd.ref(tableName).remove( onComplete )

  # Maybe OK
  on:( t, id ) ->
    tableName = @tableName(t)
    path    = if id eq '' then tableName else tableName+'/'+id
    onEvt   = 'value'
    @fd.ref(path).on( onEvt, (snapshot) =>
      key = snapshot.name()
      val = snapshot.val()
      if key? and val?
        @publish( tableName, id, 'onChange', val, { key:key } )
      else if not val?
        @publish( tableName, id, 'onChange', {}, { key:key, msg:'No Value' } )
      else
        @onerror( tableName, id, 'onChange', {}, { error:'error' } ) )
    return

  # Not used for now
  isNotEvt:( evt ) ->
    switch evt
      when 'value','child_added','child_changed','child_removed','child_moved' then false
      else                                                                          true

  # Supported? Check
  anon:( ) ->
    @fb.auth().signInAnonymously().catch( (error) =>
      if not error?
        @publish( 'none', 'none', 'anon', 'OK' )
      else
        @onerror( 'none', 'none', 'anon', {}, { error:error } ) )
    return

  # Supported? Check
  auth:( tok ) ->
    @fb.auth( tok,  ( error, result ) =>
      if not error?
        @publish( '', tok, 'auth', result.auth, { expires:new Date(result.expires * 1000) } )
      else
        @onerror( '', tok, 'auth', {}, { error:error } ) )
    return
