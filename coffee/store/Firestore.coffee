

Store          = require( 'js/store/Store' )
Store.Firebase = require( 'firebase' )

class Firestore extends Store

  module.exports   = Firestore

  constructor:( stream, uri ) ->
    super( stream, uri, 'Firestore' )
    @fb = @init( uri )
    @anon() # Anonomous logins have to enabled
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
    return

  # OK
  get:( t, id ) ->
    tableName = @tableName(t)
    @fd.ref(tableName+'/'+id).once('value', (snapshot) =>
      if snapshot.val()?
        @publish( tableName, id, 'get', snapshot.val() )
      else
        @onerror( tableName, id, 'get', {}, { msg:'Firestore get error' } ) )
    return

  # Where to put complete
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
    Util.noop( onComplete )
    #fb.ref().update( updates, onComplete )
    @fb.ref().update( updates )
    return

  # OK
  del:( t, id ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, id, 'del', {} )
      else
        @onerror( tableName, id, 'del', {}, { error:error } )
    @fd.ref(tableName).remove( id, onComplete )
    return

  # OK of set takes objects
  insert:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error }   )
    @fd.ref(tableName).set( objects, onComplete )
    return

  # OK if snapshot returns objects
  select:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @fd.ref(tableName).once('value', (snapshot) =>
      if snapshot.val()?
        objects = Util.toObjects( snapshot.val(), where, @key )
        @publish( tableName, 'none', 'select', objects, { where:where.toString() } )
      else
        @onerror( tableName, 'none', 'select', objects, { where:where.toString() } ) )
    return

  # Review - OK if update takes objects and onComplete
  update:( t, objects ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'insert', objects )
      else
        @onerror( tableName, 'none', 'insert', { error:error } )
    @fd.ref(tableName).update( objects, onComplete )
    return

  # Review - OK if this is really the right approach
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

  # Supported? are tables just child nodes
  open:( t, schema={} ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'open', {}, { schema:schema } )
      else
        @onerror( tableName, 'none', 'open', {}, { schema:schema, error:error } )
    @fd.ref().push( tableName, onComplete )
    return

  # Supported? can we access child nodes as tables
  # Need to show a table schema for one table t
  show:( t=undefined ) ->
    if t? then @showKeys(t) else @showTables()
    return

  showTables:() ->
    tables  = []
    @fd.ref().once('value', (snapshot) =>
      snapshot.forEach( (table) =>
        tables.push( table.key() )
        @publish( 'tables', 'none', 'show', tables ) ) )
    return

  showKeys:( t ) ->
    tableName = @tableName(t)
    keys  = []
    @fd.ref(t).once('value', (snapshot) =>
      snapshot.forEach( (key) =>
        keys.push( key.key() )
        @publish( tableName, 'none', 'show', keys ) ) )
    return

  # Supported? Obscure
  make:( t, alters={} ) ->
    @onerror( t, 'none', 'make', {}, { error:'Store.make() not supported', alters:alters } )
    return

  # Supported?
  drop:( t ) ->
    tableName = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( tableName, 'none', 'drop' )
      else
        @onerror( tableName, 'none', 'drop', {}, { error:error } )
    @fd.ref().remove( tableName, onComplete )
    return

  # Maybe OK
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
