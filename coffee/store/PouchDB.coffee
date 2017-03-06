
Pouch = require( 'pouchdb'        )
Store = require( 'js/store/Store' )

class PouchDB extends Store

  module.exports = PouchDB # Util.Export( PouchDB, 'store/PouchDB' )

  @CouchDBHost    = 'http://127.0.0.1:5984/'
  @CouchDBLocal   = 'http://localhost:5984/'

  constructor:( stream, uri=PouchDB.CouchDBHost  ) ->
    super( stream, uri, 'PouchDB' )
    @key = '_id' # CouchDB Id - important but not use
    @dbs = {}

  db:( t, id='none', object=null ) ->
    object['_id'] = id if object? and Util.isStr(id) and id isnt 'none'
    @dbs[t] = new Pouch( @uri + t.toLowerCase() ) if not @dbs[t]?
    @dbs[t]

  add:( t, id, object ) ->
    db = @db( t, id, object )
    db.post( object  )
      .then(  (obj) => @publish( t, id, 'add', object, obj ) )
      .catch( (err) => @onerror( t, id, 'add', object, err ) )
    return

  get:( t, id ) ->
    db = @db( t, id )
    db.get( id )
      .then(  (obj) => @publish( t, id, 'get', obj     ) )
      .catch( (err) => @onerror( t, id, 'get', {}, err ) )
    return

  put:( t, id, object ) ->
    db = @db( t, id )
    db.get( id ).then( (obj) =>
      object._id  = id
      object._rev = obj._rev
      db.put( object )
        .then(  (res) => @publish( t, id, 'del', object, res ) )
        .catch( (err) => @onerror( t, id, 'del', object, err ) ) )
      .catch( (err) => @onerror( t, id, 'del', {msg:'Unable to get doc'},  err,    ) )
    return

  del:( t, id ) ->
    db = @db( t, id )
    db.get( id ).then( (obj) =>
      obj['_deleted'] = true
      console.log( 'PouchDB.del get obj', obj )
      db.put( obj )
        .then(  (res) => @publish( t, id, 'del', obj, res ) )
        .catch( (err) => @onerror( t, id, 'del', obj, err ) ) )
      .catch( (err) => @onerror( t, id, 'del', {msg:'Unable to get doc'},  err ) )
    return

  # Right now same as update, objects without _rev will be inserted
  insert:( t, objects ) ->
    db = @db( t )
    docs = @toArray( t, objects, Store.where )
    db.bulkDocs( docs )
      .then(  (res) => @publish( t, 'none', 'insert', objects, res ) )
      .catch( (err) => @onerror( t, 'none', 'insert', objects, err ) )
    return

  select:( t, where=Store.where ) ->
    db = @db( t )
    db.allDocs( { include_docs:true } )
      .then(  (res) =>
        #console.log( 'PouchDB select res', res ) # PouchDB select results are weirdly over structured
        objects = @toSelectObjects( t, res.rows, where )
        @publish( t, 'none', 'select', objects  ) )
      .catch( (err)  =>
        @onerror( t, 'none', 'select', {}, err  ) )
    return

  # Right now same as insert except objects with  _rev will be updated
  update:( t, objects ) ->
    db   = @db( t )
    docs = @toArray( t, objects, Store.where )
    db.bulkDocs( docs )
      .then(  (res) => @publish( t, 'none', 'update', objects, res ) )
      .catch( (err) => @onerror( t, 'none', 'update', objects, err ) )
    return

  remove:( t, objects, where=Store.where ) ->
    db   = @db( t )
    docs = @toArray( t, objects, where, true )
    db.bulkDocs( docs )
      .then(  (res) => @publish( t, 'none', 'remove', objects, res ) )
      .catch( (err) => @onerror( t, 'none', 'remove', objects, err ) )
    return

  open:( t, schema ) ->
    db = db( t )
    Util.noop( db )
    @publish( t, 'none', 'open', {}, { schema:schema } )
    return

  show:( t ) ->
    db = @db( t )
    db.allDocs( { include_docs:true } )
      .then(  (rows) =>
        array = @toArray( rows )
        @publish( t, 'none', 'show', array, { rows:rows } ) )
      .catch( (err)  =>
        @onerror( t, 'none', 'show', {}, err ) )
    return

  make:( t, alters ) ->
    db = @db( t )
    Util.noop( db )
    @publish( t, 'none', 'open', {}, { alters:alters } )
    return

  drop:( t ) ->
    db = @db( t )
    @dbs[t] = null # Need to examine
    db.destroy( t )
      .then(  (info)  => @publish( t, 'none', 'drop', {}, { info:info   } ) )
      .catch( (error) => @onerror( t, 'none', 'drop', {}, error ) )
    return

  # Subscribe to  a table. Note: PouchDB can not subscript to objecst with id
  onChange:( t, id='none' ) ->
    db = @db( t, id )
    db.changes( { include_docs:true } )
      .on( 'change', (changes) => @publish( t, 'none', 'onChange', {}, changes     ) )
      .on( 'error',  (error)   => @onerror( t, 'none', 'onChange', {}, error:error ) )
    return

  toArray:( t, objects, whereIn=null, del=false ) ->
    where = if whereIn? then whereIn else () -> true
    array = []
    if Util.isArray(objects)
      for object in array  when where(object)
        object['_id']      = object['id'] if object['id']
        object['_deleted'] = true if del
        array.push( object )
    else
      for own key, object of objects when where(object)
        object['_id'] = key
        object['_deleted'] = true if del
        array.push(object)
    array

  toSelectObjects:( t, rows, whereIn, del=false ) ->
    where = if whereIn? then whereIn else () -> true
    objects = {}
    if Util.isArray(rows)
      for row in rows when where(row.doc)
        row['_deleted'] = true if del
        objects[row.doc['id']] = row.doc # Weird PouchDB structure
    else
      for key, row of rows when where(row)
        row['_deleted'] = true if del
        objects[key]  = row
    objects
