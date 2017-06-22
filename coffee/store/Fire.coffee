
Store          = require( 'js/store/Store' )
Store.Firebase = firebase #require( 'firebase' )

class Fire extends Store

  module.exports   = Fire

  @OnFire  = { get:"value", add:"child_added", put:"child_changed", del:"child_removed" }

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
        @publish( tableName, 'add', id, object )
      else
        @onError( tableName, 'add', id, object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )
    return

  get:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        @publish( tableName, 'get', id, snapshot.val() )
      else
        @onError( tableName, 'get', id, { msg:'Fire get error' } )
    @fd.ref(tableName+'/'+id).once('value', onComplete )
    return

  # Same as add
  put:( t, id,  object ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'put', id, object )
      else
        @onError( tableName, 'put', id, object, { error:error } )
    @fd.ref(tableName+'/'+id).set( object, onComplete )
    return

  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'del', id, {} )
      else
        @onError( tableName, 'del', id, {}, { error:error } )
    @fd.ref(tableName+'/'+id).remove( onComplete )
    return

  insert:( t, objects ) ->
    tableName  = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'insert', 'none', objects )
      else
        @onError( tableName, 'insert', 'none', { error:error } )
    @fd.ref(tableName).set( objects, onComplete )
    return

  select:( t, where=Store.where ) ->
    Util.noop( where )
    tableName = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        #val = @toObjects( snapshot.val() )
        @publish( tableName, 'select', 'none', snapshot.val() )
      else
        @publish( tableName, 'select', 'none', {} ) # Publish empty results
    @fd.ref(tableName).once('value', onComplete )
    return

  range:( t, beg, end ) ->
    tableName = @tableName(t)
    #Util.log( 'Fire.range  beg', t, beg, end )
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        val = @toObjects( snapshot.val() )
        @publish( tableName, 'range', 'none', val )
      else
        @publish( tableName, 'range', 'none', {}  )  # Publish empty results
    @fd.ref(tableName).orderByKey().startAt(beg).endAt(end).once('value', onComplete )
    return

  update:( t, objects ) ->
    tableName  = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'update', 'none', objects )
      else
        @onError( tableName, 'update', 'none', { error:error } )
    @fd.ref(tableName).update( objects, onComplete )
    return

  remove:( t, keys ) ->
    tableName = @tableName(t)
    ref       = @fd.ref(t)
    ref.child(key).remove() for key in keys
    @publish( tableName, 'remove', 'none', keys )
    return

  make:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'make', 'none', {}, {} )
      else
        @onError( tableName, 'make', 'none', {}, { error:error } )
    @fd.ref().set( tableName, onComplete )
    return

  show:( t, where=Store.where ) ->
    tableName  = if t? then @tableName(t) else @dbName
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        keys = Util.toKeys( snapshot.val(), where, @keyProp )
        @publish( tableName, 'show', 'none', keys, { where:where.toString() } )
      else
        @onError( tableName, 'show', 'none', {},   { where:where.toString() } )
    if t?
      @fd.ref(tableName).once('value', onComplete )
    else
      @fd.ref(         ).once('value', onComplete )
    return

  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'drop', 'none', "OK" )
      else
        @onError( tableName, 'drop', 'none', {}, { error:error } )
    @fd.ref(tableName).remove( onComplete )
    return

  # Have too clarify id with snapshot.key
  on:( t, onEvt, id='none', onFunc=null ) ->
    table  = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot?
        key = snapshot.key
        val = snapshot.val() # @toObjects( snapshot.val() )
        if onFunc?
           onFunc( key, val )
        else
           @publish( table, onEvt, key, val )
      else
        @onError( table, onEvt, id, {}, { error:'error' } )
    path  = if id is 'none' then table else table + '/' + id
    @fd.ref(path).on( Fire.OnFire[onEvt], onComplete )
    return

  # keyProp only needed if rows is array
  toObjects:( rows ) ->
    objects = {}
    if Util.isArray(rows)
      for row in rows
        if row? and row['key']?
          ckey = row['key'].split('/')[0]
          objects[row[ckey]] = @toObjects(row)
          Util.log( 'Fire.toObjects', { rkowKey:row['key'], ckey:ckey, row:row } )
        else
          Util.error( "Fire.toObjects() row array element requires key property", row )
    else
      objects = rows
    objects

  # Sign Anonymously
  auth:( ) ->
   onerror = (error) =>
     @onError( 'none', 'none', 'anon', {}, { error:error } )
   @fb.auth().signInAnonymously().catch( onerror )
   return

