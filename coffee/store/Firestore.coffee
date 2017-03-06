

Store          = require( 'js/store/Store' )
Store.Firebase = require( 'firebase' )

class Firestore extends Store

  module.exports   = Firestore

  constructor:( stream, uri ) ->
    super( stream, uri, 'Firestore' )
    @fb = @init( uri )

  init:( uri ) ->
    Util.noop( uri )
    config = {
      apiKey:       "AIzaSyBjMGVzZ6JgZBs8O7mBQfH6clHYDmjTsGU",
      authDomain:   "skyline-fed2b.firebaseapp.com",
      databaseURL:  "https://skyline-fed2b.firebaseio.com",
      storageBucket: "",
      messagingSenderId: "279547846849" }
    Store.Firebase .initializeApp(config)
    Store.Firebase
    return

  ###
  openFireBaseDB:( uri ) ->
    FirestoreDB.initializeApp( { apiKey:FireBaseApiKey, databaseURL:uri } )
    FirestoreDB.database().ref()
  ###


  add:( t, id, object  ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'add', object )
      else
        @onerror( tableName, id, 'add', object, { error:error } )
    @fb.child(tableName+'/'+id).set( object, onComplete )
    return

  get:( t, id ) ->
    tableName = @tableName(t)
    @fb.child(tableName+'/'+id).once('value', (snapshot) =>
      if snapshot.val()?
        @publish( tableName, id, 'get', snapshot.val() )
      else
        @onerror( tableName, id, 'get', {}, { msg:'Firestore get error' } ) )
    return

  put:( t, id,  object ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'put', object )
      else
        @onerror( tableName, id, 'put', object, { error:error } )
    @fb.child(tableName+'/'+id).update( object, onComplete )
    return

  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'del', {} )
      else
        @onerror( tableName, id, 'del', {}, { error:error } )
    @fb.child(tableName).remove( id, onComplete )
    return

  insert:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error }   )
    @fb.child(tableName).set( objects, onComplete )
    return

  select:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @fb.child(tableName).once('value', (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        @publish( tableName, 'none', 'select', objects, { where:where.toString() } )
      else
        @onerror( tableName = @tableName(t), 'none', 'select', objects, { where:where.toString() } ) )
    return

  update:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error } )
    @fb.child(tableName).update( objects, onComplete )
    return

  remove:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @fb.child(t).once('value', (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        for key, object of objects when where(val)
          @fb.child(t).remove( key ) # Need to see if onComplete is needed
        @publish( tableName, 'none', 'remove', objects, { where:where.toString() } )
      else
        @onerror( tableName, 'none', 'remove', objects, { where:where.toString() } ) )
    return

  open:( t, schema ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'open', {}, { schema:schema } )
      else
        @onerror( tableName, 'none', 'open', {}, { schema:schema, error:error } )
    fb.set( tableName, onComplete )
    return

  # Need to show a table schema for one table t
  show:( t ) ->
    tableName = @tableName(t)
    keys  = []
    @fb.once('value', (snapshot) =>
      snapshot.forEach( (table) =>
        keys.push( table.key() )
      @publish( tableName, 'none', 'show', keys ) ) )
    return

  make:( t, alters ) ->
    tableName = @tableName(t)
    @publish( tableName = @tableName(t), 'none', 'make', {}, { alters:alters } )
    return

  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName = @tableName(t), 'none', 'drop' )
      else
        @onerror( tableName = @tableName(t), 'none', 'drop', {}, { error:error } )
    @fb.remove( tableName = @tableName(t), onComplete )
    return

  onChange:( t, id ) ->
    tableName = @tableName(t)
    path    = if id eq '' then tableName else tableName+'/'+id
    onEvt   = 'value'
    @fb.child(path).on( onEvt, (snapshot) =>
      key = snapshot.name()
      val = snapshot.val()
      if key? and val?
        @publish( tableName, id, 'onChange', val, { key:key } )
      else if not val?
        @publish( tableName, id, 'onChange', {}, { key:key, msg:'No Value' } )
      else
        @onerror( tableName, id, 'onChange', {}, { error:'error' } ) )
    return

  isNotEvt:( evt ) ->
    switch evt
      when 'value','child_added','child_changed','child_removed','child_moved' then false
      else                                                                          true

  auth:( tok ) ->
    @fb.auth( tok,  ( error, result ) =>
      if not error?
        @publish( '', tok, 'auth', result.auth, { expires:new Date(result.expires * 1000) } )
      else
        @onerror( '', tok, 'auth', {}, { error:error } ) )
    return
