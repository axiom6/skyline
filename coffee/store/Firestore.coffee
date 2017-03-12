

Store          = require( 'js/store/Store' )
Store.Firebase = require( 'firebase' )

class Firestore extends Store

  module.exports   = Firestore

  @EventOn = { value:"onVal", child_added:"onAdd", child_changed:"onPut", child_removed:"onDel", child_moved:"onMov" }
  @OnEvent = { onVal:"value", onAdd:"child_added", onPut:"child_changed", onDel:"child_removed", onMov:"child_moved" }

  constructor:( stream, uri, @config ) ->
    super( stream, uri, 'Firestore' )
    @fb = @init( @config ) # @dbName set by Store in super constructor
    @auth() # Anonomous logins have to enabled
    @fd = Store.Firebase.database()

  init:( config ) ->
    Store.Firebase.initializeApp(config)
    Util.log( 'Firestore.init', config )
    Store.Firebase

  add:( t, id, object  ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'add', object )
      else
        @onerror( tableName, id, 'add', object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )

  get:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        @publish( tableName, id, 'get', snapshot.val() )
      else
        @onerror( tableName, id, 'get', {}, { msg:'Firestore get error' } )
    @fd.ref(tableName+'/'+id).once('value', onComplete )

  # Same as add
  put:( t, id,  object ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'put', object )
      else
        @onerror( tableName, id, 'put', object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )

  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'del', {} )
      else
        @onerror( tableName, id, 'del', {}, { error:error } )
    @fd.ref(tableName+'/'+id).remove( onComplete )

  insert:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error } )
    @fd.ref(tableName).set( objects, onComplete )

  select:( t, where=Store.where ) ->
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
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
      if snapshot? and snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        for key, object of objects when where(val)
          @fb.ref(t).remove( key ) # Need to see if onComplete is needed
        @publish( tableName, 'none', 'remove', objects, { where:where.toString() } )
      else
        @onerror( tableName, 'none', 'remove', objects, { where:where.toString() } )
    @fd.ref(t).once('value', onComplete )

  make:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'make', {}, {} )
      else
        @onerror( tableName, 'none', 'make', {}, { error:error } )
    @fd.ref().set( tableName, onComplete )

  show:( t=undefined ) ->
    tableName = if t? then @tableName(t) else @dbName
    keys  = []
    onComplete = (snapshot) =>
      if snapshot?
        snapshot.forEach( (child) =>
          keys.push( child.key ) )
        @publish( tableName, 'none', 'show', keys )
      else
        @onerror( tableName, 'none', 'show', {}, { error:'error' } )
    if t?
      @fd.ref(tableName).once('value', onComplete )
    else
      @fd.ref(         ).once('value', onComplete )

  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'drop', "OK" )
      else
        @onerror( tableName, 'none', 'drop', {}, { error:error } )
    @fd.ref(tableName).remove( onComplete )

  on:( onEvt, t, id='none' ) ->
    table  = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot?
        key = snapshot.key
        val = snapshot.val()
        @publish( table, id, onEvt, { onEvt:onEvt, table:table, key:key, val:val } )
      else
        @onerror( table, id, onEvt, {}, { error:'error' } )
    path  = if id is 'none' then table else table + '/' + id
    @fd.ref(path).on( Firestore.OnEvent[onEvt], onComplete )

  # Sign Anonymously
  auth:( ) ->
   onError = (error) =>
     @onerror( 'none', 'none', 'anon', {}, { error:error } )
   @fb.auth().signInAnonymously().catch( onError )

