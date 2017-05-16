
Store          = require( 'js/store/Store' )
Store.Firebase = firebase #require( 'firebase' )

class Fire extends Store

  module.exports   = Fire

  @EventOn = { value:"onVal", child_added:"onAdd", child_changed:"onPut", child_removed:"onDel", child_moved:"onMov" }
  @OnEvent = { onVal:"value", onAdd:"child_added", onPut:"child_changed", onDel:"child_removed", onMov:"child_moved" }

  constructor:( stream, uri, @config ) ->
    super( stream, uri, 'Fire' ) # @dbName set by Store in super constructor
    @fb = @init( @config )
    @auth() # Anonomous logins have to enabled
    @fd = Store.Firebase.database()

  init:( config ) ->
    Store.Firebase.initializeApp(config)
    #Util.log( 'Fires.init', config )
    Store.Firebase

  add:( t, id, object  ) ->
    tableName = @tableName(t)
    object[@keyProp] = id
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'add', object )
      else
        @onError( tableName, id, 'add', object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )
    return

  get:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        object = snapshot.val()
        object[@keyProp] = id
        @publish( tableName, id, 'get', object )
      else
        @onError( tableName, id, 'get', { msg:'Fire get error' } )
    @fd.ref(tableName+'/'+id).once('value', onComplete )
    return

  # Same as add
  put:( t, id,  object ) ->
    tableName = @tableName(t)
    object[@keyProp] = id
    onComplete = (error) =>
      if not error?
        object[@keyProp] = id
        @publish( tableName, id, 'put', object )
      else
        @onError( tableName, id, 'put', object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )
    return

  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'del', {} )
      else
        @onError( tableName, id, 'del', {}, { error:error } )
    @fd.ref(tableName+'/'+id).remove( onComplete )
    return

  insert:( t, objects ) ->
    tableName  = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onError( tableName, 'none', 'insert', { error:error } )
    @fd.ref(tableName).set( objects, onComplete )
    return

  select:( t, where=Store.where ) ->
    Util.noop( where )
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        @publish( tableName, 'none', 'select', snapshot.val() )
      else
        @publish( tableName, 'none', 'select', {} ) # Publish empty results
    @fd.ref(tableName).once('value', onComplete )
    return

  range:( t, beg, end ) ->
    tableName = @tableName(t)
    #Util.log( 'Fire.range  beg', t, beg, end )
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        @publish( tableName, 'none', 'range', snapshot.val() )
      else
        @publish( tableName, 'none', 'range', {} )  # Publish empty results
    @fd.ref(tableName).orderByKey().startAt(beg).endAt(end).once('value', onComplete )
    return

  update:( t, objects ) ->
    tableName  = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'update', objects )
      else
        @onError( tableName, 'none', 'update', { error:error } )
    @fd.ref(tableName).update( objects, onComplete )
    return

  remove:( t, keys ) ->
    tableName = @tableName(t)
    ref       = @fd.ref(t)
    ref.child(key).remove() for key in keys
    @publish( tableName, 'none', 'remove', keys )
    return

  make:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'make', {}, {} )
      else
        @onError( tableName, 'none', 'make', {}, { error:error } )
    @fd.ref().set( tableName, onComplete )
    return

  show:( t, where=Store.where ) ->
    tableName  = if t? then @tableName(t) else @dbName
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        keys = Util.toKeys( snapshot.val(), where, @keyProp )
        @publish( tableName, 'none', 'show', keys, { where:where.toString() } )
      else
        @onError( tableName, 'none', 'show', {},   { where:where.toString() } )
    if t?
      @fd.ref(tableName).once('value', onComplete )
    else
      @fd.ref(         ).once('value', onComplete )
    return

  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'drop', "OK" )
      else
        @onError( tableName, 'none', 'drop', {}, { error:error } )
    @fd.ref(tableName).remove( onComplete )
    return

  # Have too clarify id with snapshot.key
  on:( t, onEvt, id='none' ) ->
    table  = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot?
        key = snapshot.key
        val = snapshot.val()
        @publish( table, id, onEvt, { onEvt:onEvt, table:table, key:key, val:val } )
        Util.log( 'Fire.on()', table, onEvt, key, val )
      else
        @onError( table, id, onEvt, {}, { error:'error' } )
    path  = if id is 'none' then table else table + '/' + id
    @fd.ref(path).on( Fire.OnEvent[onEvt], onComplete )
    return

  # Sign Anonymously
  auth:( ) ->
   onerror = (error) =>
     @onError( 'none', 'none', 'anon', {}, { error:error } )
   @fb.auth().signInAnonymously().catch( onerror )
   return

