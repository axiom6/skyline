

Store          = require( 'js/store/Store' )
Store.Firebase = require( 'firebase' )

class Firestore extends Store

  module.exports   = Firestore

  constructor:( stream, uri ) ->
    super( stream, uri, 'Firestore' )
    @fb = @init( uri )
    @fd = Store.Firebase.database()

  init:( uri ) ->
    Util.noop( uri )
    config = {
      apiKey:       "AIzaSyBjMGVzZ6JgZBs8O7mBQfH6clHYDmjTsGU",
      authDomain:   "skyline-fed2b.firebaseapp.com",
      databaseURL:  "https://skyline-fed2b.firebaseio.com",
      storageBucket: "",
      messagingSenderId: "279547846849" }
    Store.Firebase.initializeApp(config)
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
    @fd.ref(tableName+'/'+id).set( object, onComplete )
    return

  get:( t, id ) ->
    tableName = @tableName(t)
    @fd.ref(tableName+'/'+id).once('value', (snapshot) =>
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
    putKey  = @fd.ref().child('tableName').push().key
    updates = {}
    updates[tableName+'/'+id+putKey] = object # Not Sure
    #fb.ref().update( updates, onComplete )
    @fb.ref().update( updates )
    return

  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'del', {} )
      else
        @onerror( tableName, id, 'del', {}, { error:error } )
    @fd.ref(tableName).remove( id, onComplete )
    return

  insert:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error }   )
    @fd.ref(tableName).set( objects, onComplete )
    return

  # Review
  select:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @fd.ref(tableName).once('value', (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        @publish( tableName, 'none', 'select', objects, { where:where.toString() } )
      else
        @onerror( tableName = @tableName(t), 'none', 'select', objects, { where:where.toString() } ) )
    return

  # Review
  update:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error } )
    @fd.ref(tableName).update( objects, onComplete )
    return

  # Review
  remove:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @fd.ref(t).once('value', (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        for key, object of objects when where(val)
          @fb.ref(t).remove( key ) # Need to see if onComplete is needed
        @publish( tableName, 'none', 'remove', objects, { where:where.toString() } )
      else
        @onerror( tableName, 'none', 'remove', objects, { where:where.toString() } ) )
    return

  # Supported?
  open:( t, schema ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'open', {}, { schema:schema } )
      else
        @onerror( tableName, 'none', 'open', {}, { schema:schema, error:error } )
    fb.set( tableName, onComplete )
    return

  # Supported?
  # Need to show a table schema for one table t
  show:( t ) ->
    tableName = @tableName(t)
    keys  = []
    @fd.once('value', (snapshot) =>
      snapshot.forEach( (table) =>
        keys.push( table.key() )
      @publish( tableName, 'none', 'show', keys ) ) )
    return

  # Supported? Obscure
  make:( t, alters ) ->
    tableName = @tableName(t)
    @publish( tableName = @tableName(t), 'none', 'make', {}, { alters:alters } )
    return

  # Supported?
  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName = @tableName(t), 'none', 'drop' )
      else
        @onerror( tableName = @tableName(t), 'none', 'drop', {}, { error:error } )
    @fd.ref(t).remove( tableName, onComplete )
    return

  # Needs Work
  onChange:( t, id ) ->
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

  isNotEvt:( evt ) ->
    switch evt
      when 'value','child_added','child_changed','child_removed','child_moved' then false
      else                                                                          true

  # Supported? Check
  auth:( tok ) ->
    @fb.auth( tok,  ( error, result ) =>
      if not error?
        @publish( '', tok, 'auth', result.auth, { expires:new Date(result.expires * 1000) } )
      else
        @onerror( '', tok, 'auth', {}, { error:error } ) )
    return
