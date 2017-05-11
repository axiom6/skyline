
Store = require( 'js/store/Store' )

class Memory extends Store

  module.exports = Memory

  constructor:( stream, uri ) ->
    super( stream, uri, 'Memory' )
    Store.databases[@dbName] = @tables
    Util .databases[@dbName] = @tables

  add:( t, id, object  )    ->
    @table(t)[id] = object
    @publish( t, id, 'add', object )
    return

  get:( t, id ) ->
    object  = @table(t)[id]
    if object?
      @publish( t, id, 'get', object )
    else
      @onerror( t, id, 'get', object,  { msg:"Id #{id} not found"} )
    return

  put:( t, id,  object ) ->
    @table(t)[id] = object
    @publish( t, id, 'put', object )
    return

  del:( t, id ) ->
    object  = @table(t)[id]
    if object?
      delete @table(t)[id]
      @publish( t, id, 'del', object )
    else
      @onerror( t, id, 'del', object,  { msg:"Id #{id} not found"} )
    return

  insert:( t, objects ) ->
    table   = @table(t)
    for own key, object of objects
      table[key] = object
    @publish( t, 'none', 'insert', objects )
    return

  select:( t, where ) ->
    objects =  {}
    table   = @table(t)
    for own key, object of table when where(object)
      objects[key] = object
    @publish( t, 'none', 'select', objects, { where:where.toString() } )
    return

  range:( t, beg, end ) ->
    objects =  {}
    table   = @table(t)
    for own key, object of table when beg <= key and key <= end
      objects[key] = object
    @publish( t, 'none', 'range', objects, { beg:beg.toString(), end:end.toString() } )

  update:( t, objects ) ->
    table = @table(t)
    for own key, object of objects
      table[key] = object
    @publish( t, id, 'update', objects )
    return

  remove:( t, where=Store.where ) ->
    table = @table(t)
    objects = {}
    for own key, object of table when where(object)
      objects[key] = object
      delete object[key]
    @publish( t, 'none', 'remove', objects, { where:where.toString() } )
    return

  make:( t ) ->
    @createTable(t)
    @publish( t, 'none', 'open', {}, {} )
    return

  show:( t ) ->
    if Util.isStr(t)
      keys = []
      for own key, val of @tables[t]
        keys.push(key)
      @publish( t, 'none', 'show', keys,  { showing:'keys' } )
    else
      tables = []
      for own key, val of @tables
        tables.push(key)
      @publish( t, 'none', 'show', tables, { showing:'tables' } )
    return

  drop:( t ) ->
    hasTable = @tables[t]?
    if hasTable
      delete  @tables[t]
      @publish( t, 'none', 'drop', {} )
    else
      @onerror( t, 'none', 'drop', {}, { msg:"Table #{t} not found"} )
    return

  # Subscribe to  a table or object with id
  on:(  t, id='none'   ) ->
    @onerror( t, id, 'on', {}, { msg:"on() not implemeted by Store.Memory" } )
    return

  dbTableName:( tableName ) ->
    @dbName + '/' + tableName

  importLocalStorage:( tableNames ) ->
    for tableName in tableNames
      @tables[tableName] = JSON.parse(localStorage.getItem(@dbTableName(tableName)))
    return

  exportLocalStorage:() ->
    for own tableName, table of @tables
      dbTableName = @dbTableName(tableName)
      localStorage.removeItem( dbTableName  )
      localStorage.setItem(    dbTableName, JSON.stringify(table) )
      # Util.log( 'Store.Memory.exportLocalStorage()', dbTableName )
    return

  importIndexDb:( op ) ->
    IDB = require( 'js/store/IndexedDB')
    idb = new IDB( @stream, @dbName )
    for tableName in idb.dbs.objectStoreNames
      onNext = (result) =>
         @tables[tableName] = result if op is 'select'
      @subscribe( tableName, onNext )
      idb.traverse( 'select', tableName, {}, Store.where(), false )
    return

  exportIndexedDb:() ->
    dbVersion = 1
    IDB = require( 'js/store/IndexedDB')
    idb = new IDB( @stream, @dbName, dbVersion, @tables )
    onIdxOpen = (dbName) =>
      idb.deleteDatabase( dbName )
      for own name, table of @tables
        onNext = (result) =>
          Util.noop( dbName, result )
        @subscribe( name, 'none', 'insert', onNext )
        idb.insert( name, table  )
    @subscribe( 'IndexedDB', dbVersion.toString(), 'open', (dbName) => onIdxOpen(dbName) )
    idb.openDatabase()
    return

  tableNames:() ->
    names = []
    for own key, table of @tables
      names.push(key)
    names

  logRows:( name, table ) ->
    Util.log( name )
    for own key, row of table
      Util.log( '  ', key )
      Util.log( '  ', row )
      Util.log( '  ',  JSON.stringify( row ) )
