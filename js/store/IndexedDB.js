// Generated by CoffeeScript 1.12.2
(function() {
  var IndexedDB, Store,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Store = require('js/store/Store');

  IndexedDB = (function(superClass) {
    extend(IndexedDB, superClass);

    module.exports = IndexedDB;

    function IndexedDB(stream, uri, dbVersion, tableNames) {
      this.dbVersion = dbVersion != null ? dbVersion : 1;
      this.tableNames = tableNames != null ? tableNames : [];
      IndexedDB.__super__.constructor.call(this, stream, uri, 'IndexedDB');
      this.indexedDB = window.indexedDB;
      if (!this.indexedDB) {
        Util.error('Store.IndexedDB.constructor indexedDB not found');
      }
      this.dbs = null;
    }

    IndexedDB.prototype.add = function(t, id, object) {
      var req, tableName, txo;
      tableName = this.tableName(t);
      txo = this.txnObjectStore(tableName, "readwrite");
      req = txo.add(obj, id);
      req.onsuccess = (function(_this) {
        return function() {
          return _this.publish(tableName, id, 'add', object);
        };
      })(this);
      req.onerror = (function(_this) {
        return function() {
          return _this.onerror(tableName, id, 'add', object, {
            error: req.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.get = function(t, id) {
      var req, tableName, txo;
      tableName = this.tableName(t);
      txo = this.txnObjectStore(tableName, "readonly");
      req = txo.get(id);
      req.onsuccess = (function(_this) {
        return function() {
          return _this.publish(tableName, id, 'get', req.result);
        };
      })(this);
      req.onerror = (function(_this) {
        return function() {
          return _this.onerror(tableName, id, 'get', req.result, {
            error: req.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.put = function(t, id, object) {
      var req, tableName, txo;
      tableName = this.tableName(t);
      txo = this.txnObjectStore(tableName, "readwrite");
      req = txo.put(object);
      req.onsuccess = (function(_this) {
        return function() {
          return _this.publish(tableName, id, 'put', object);
        };
      })(this);
      req.onerror = (function(_this) {
        return function() {
          return _this.onerror(tableName, id, 'put', object, {
            error: req.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.del = function(t, id) {
      var req, tableName, txo;
      tableName = this.tableName(t);
      txo = this.txnObjectStore(tableName, "readwrite");
      req = txo['delete'](id);
      req.onsuccess = (function(_this) {
        return function() {
          return _this.publish(tableName, id, 'del', req.result);
        };
      })(this);
      req.onerror = (function(_this) {
        return function() {
          return _this.onerror(tableName, id, 'del', req.result, {
            error: req.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.insert = function(t, objects) {
      var key, object, tableName, txo;
      tableName = this.tableName(t);
      txo = this.txnObjectStore(t, "readwrite");
      for (key in objects) {
        if (!hasProp.call(objects, key)) continue;
        object = objects[key];
        object = this.idProp(key, object, this.key);
        txo.put(object);
      }
      this.publish(tableName, 'none', 'insert', objects);
    };

    IndexedDB.prototype.select = function(t, where) {
      var tableName;
      if (where == null) {
        where = Store.where;
      }
      tableName = this.tableName(t);
      this.traverse('select', tableName, where);
    };

    IndexedDB.prototype.update = function(t, objects) {
      var key, object, tableName, txo;
      tableName = this.tableName(t);
      txo = this.txnObjectStore(t, "readwrite");
      for (key in objects) {
        if (!hasProp.call(objects, key)) continue;
        object = objects[key];
        object = this.idProp(key, object, this.key);
        txo.put(object);
      }
      this.publish(tableName, 'none', 'update', objects);
    };

    IndexedDB.prototype.remove = function(t, where) {
      var tableName;
      if (where == null) {
        where = Store.where;
      }
      tableName = this.tableName(t);
      this.traverse('remove', tableName, where);
    };

    IndexedDB.prototype.open = function(t, schema) {
      var tableName;
      tableName = this.tableName(t);
      this.publish(tableName, 'none', 'open', {}, {
        schema: schema
      });
    };

    IndexedDB.prototype.show = function(t) {
      var tableName;
      tableName = this.tableName(t);
      this.traverse('show', tableName, objects, where, false);
    };

    IndexedDB.prototype.make = function(t, alters) {
      var tableName;
      tableName = this.tableName(t);
      this.publish(tableName, 'none', 'make', {}, {
        alters: alters
      });
    };

    IndexedDB.prototype.drop = function(t) {
      var tableName;
      tableName = this.tableName(t);
      this.dbs.deleteObjectStore(t);
      this.publish(tableName, 'none', 'drop');
    };

    IndexedDB.prototype.on = function(t, id) {
      var tableName;
      if (id == null) {
        id = 'none';
      }
      tableName = this.tableName(t);
      this.onerror(tableName, id, 'onChange', {}, {
        msg: "on() not implemeted by Store.IndexedDb"
      });
    };

    IndexedDB.prototype.idProp = function(id, object, key) {
      if (object[key] == null) {
        object[key] = id;
      }
      return object;
    };

    IndexedDB.prototype.txnObjectStore = function(t, mode, key) {
      var txn, txo;
      if (key == null) {
        key = this.key;
      }
      txo = null;
      if (this.dbs == null) {
        Util.trace('Store.IndexedDb.txnObjectStore() @dbs null');
      } else if (this.dbs.objectStoreNames.contains(t)) {
        txn = this.dbs.transaction(t, mode);
        txo = txn.objectStore(t, {
          keyPath: key
        });
      } else {
        Util.error('Store.IndexedDb.txnObjectStore() missing objectStore for', t);
      }
      return txo;
    };

    IndexedDB.prototype.traverse = function(op, t, where) {
      var mode, req, txo;
      mode = op === 'select' ? 'readonly' : 'readwrite';
      txo = this.txnObjectStore(t, mode);
      req = txo.openCursor();
      req.onsuccess = (function(_this) {
        return function(event) {
          var cursor, objects;
          objects = {};
          cursor = event.target.result;
          if (cursor != null) {
            if (op === 'select' && where(cursor.value)) {
              objects[cursor.key] = cursor.value;
            }
            if (op === 'remove' && where(cursor.value)) {
              cursor["delete"]();
            }
            cursor["continue"]();
          }
          return _this.publish(t, 'none', op, objects, {
            where: 'all'
          });
        };
      })(this);
      req.onerror = (function(_this) {
        return function() {
          return _this.onerror(t, 'none', op, {}, {
            where: 'all',
            error: req.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.createObjectStores = function() {
      var i, len, ref, t;
      if (this.tableNames != null) {
        ref = this.tableNames;
        for (i = 0, len = ref.length; i < len; i++) {
          t = ref[i];
          if (!this.dbs.objectStoreNames.contains(t)) {
            this.dbs.createObjectStore(t, {
              keyPath: this.key
            });
          }
        }
      } else {
        Util.error('Store.IndexedDB.createTables() missing @tableNames');
      }
    };

    IndexedDB.prototype.openDatabase = function() {
      var request;
      request = this.indexedDB.open(this.dbName, this.dbVersion);
      request.onupgradeneeded = (function(_this) {
        return function(event) {
          _this.dbs = event.target.result;
          _this.createObjectStores();
          return Util.log('Store.IndexedDB', 'upgrade', _this.dbName, _this.dbs.objectStoreNames);
        };
      })(this);
      request.onsuccess = (function(_this) {
        return function(event) {
          _this.dbs = event.target.result;
          Util.log('Store.IndexedDB', 'open', _this.dbName, _this.dbs.objectStoreNames);
          return _this.publish('none', 'none', 'open', _this.dbs.objectStoreNames);
        };
      })(this);
      return request.onerror = (function(_this) {
        return function() {
          Util.error('Store.IndexedDB.openDatabase() unable to open', {
            database: _this.dbName,
            error: request.error
          });
          return _this.onerror('none', 'none', 'open', _this.dbName, {
            error: request.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.deleteDatabase = function(dbName) {
      var request;
      request = this.indexedDB.deleteDatabase(dbName);
      request.onsuccess = (function(_this) {
        return function() {
          return Util.log('Store.IndexedDB.deleteDatabase() deleted', {
            database: dbName
          });
        };
      })(this);
      request.onerror = (function(_this) {
        return function() {
          return Util.error('Store.IndexedDB.deleteDatabase() unable to delete', {
            database: dbName,
            error: request.error
          });
        };
      })(this);
      return request.onblocked = (function(_this) {
        return function() {
          return Util.error('Store.IndexedDB.deleteDatabase() database blocked', {
            database: dbName,
            error: request.error
          });
        };
      })(this);
    };

    IndexedDB.prototype.close = function() {
      if (this.dbs != null) {
        return this.dbs.close();
      }
    };

    return IndexedDB;

  })(Store);

}).call(this);
