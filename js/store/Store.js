// Generated by CoffeeScript 1.12.2
(function() {
  var Store,
    hasProp = {}.hasOwnProperty;

  Store = (function() {
    var W;

    module.exports = Store;


    /*
    Store.Memory    = require( 'js/store/Memory'     )
    Store.IndexedDB = require( 'js/store/IndexedDB'  )
    Store.Rest      = require( 'js/store/Rest'       )
    Store.Fire      = require( 'js/store/Fire'       )
     */

    Store.memories = {};

    Store.databases = {};

    Store.restOps = ['add', 'get', 'put', 'del'];

    Store.sqlOps = ['insert', 'select', 'update', 'remove', 'range'];

    Store.tableOps = ['open', 'show', 'make', 'drop'];

    Store.isRestOp = function(op) {
      return Store.restOps.indexOf(op) !== -1;
    };

    Store.isSqlOp = function(op) {
      return Store.sqlOps.indexOf(op) !== -1;
    };

    Store.isTableOp = function(op) {
      return Store.tableOps.indexOf(op) !== -1;
    };

    Store.methods = Store.restOps.concat(Store.sqlOps).concat(Store.tableOps).concat(['on']);

    Store.where = function() {
      return true;
    };

    W = Store.where;

    function Store(stream1, uri1, module1) {
      this.stream = stream1;
      this.uri = uri1;
      this.module = module1;
      this.keyProp = 'key';
      this.dbName = Store.nameDb(this.uri);
      this.tables = {};
      this.hasMemory = false;
      this.justMemory = false;
    }

    Store.prototype.add = function(table, id, object) {
      return Util.noop(table, id, object);
    };

    Store.prototype.get = function(table, id) {
      return Util.noop(table, id);
    };

    Store.prototype.put = function(table, id, object) {
      return Util.noop(table, id, object);
    };

    Store.prototype.del = function(table, id) {
      return Util.noop(table, id);
    };

    Store.prototype.insert = function(table, objects) {
      return Util.noop(table, objects);
    };

    Store.prototype.select = function(table, where) {
      if (where == null) {
        where = W;
      }
      return Util.noop(table, where);
    };

    Store.prototype.range = function(table, beg, end) {
      return Util.noop(table, beg, end);
    };

    Store.prototype.update = function(table, objects) {
      return Util.noop(table, objects);
    };

    Store.prototype.remove = function(table, wheKeys) {
      return Util.noop(table, wheKeys);
    };

    Store.prototype.make = function(table) {
      return Util.noop(table);
    };

    Store.prototype.show = function(table) {
      if (table == null) {
        table = void 0;
      }
      return Util.noop(table);
    };

    Store.prototype.drop = function(table) {
      return Util.noop(table);
    };

    Store.prototype.on = function(t, op, id, onFunc) {
      var onNext, table;
      if (id == null) {
        id = 'none';
      }
      if (onFunc == null) {
        onFunc = null;
      }
      table = this.tableName(t);
      onNext = onFunc != null ? onFunc : (function(_this) {
        return function(result) {
          return Util.log('Store.on()', result);
        };
      })(this);
      this.subscribe(table, op, id, onNext);
    };

    Store.prototype.createTable = function(t) {
      this.tables[t] = {};
      return this.tables[t];
    };

    Store.prototype.table = function(t) {
      if (this.tables[t] != null) {
        return this.tables[t];
      } else {
        return this.createTable(t);
      }
    };

    Store.prototype.tableName = function(t) {
      var name, table;
      name = Util.firstTok(t, '.');
      table = this.table(name);
      Util.noop(table);
      return name;
    };

    Store.prototype.memory = function(table, op, id) {
      var onNext;
      onNext = (function(_this) {
        return function(data) {
          return _this.toMemory(op, table, id, data);
        };
      })(this);
      this.stream.subscribe(this.toSubject(table, op, id), onNext, this.onError, this.onComplete);
    };

    Store.prototype.subscribe = function(table, op, id, onNext) {
      this.stream.subscribe(this.toSubject(table, id, op), onNext, this.onError, this.onComplete);
    };

    Store.prototype.publish = function(table, op, id, data, extras) {
      if (extras == null) {
        extras = {};
      }
      Util.noop(extras);
      this.stream.publish(this.toSubject(table, id, op), data);
    };

    Store.prototype.onError = function(table, op, id, result, error) {
      if (result == null) {
        result = {};
      }
      if (error == null) {
        error = {};
      }
      console.log('Store.onError', {
        db: this.dbName,
        table: table,
        op: op,
        id: id,
        result: result,
        error: error
      });
    };

    Store.prototype.toMemory = function(op, table, id, data, params) {
      var memory;
      if (params == null) {
        params = Store;
      }
      memory = this.getMemory(this.dbName);
      switch (op) {
        case 'add':
          memory.add(table, id, data);
          break;
        case 'get':
          memory.add(table, id, data);
          break;
        case 'put':
          memory.put(table, id, data);
          break;
        case 'del':
          memory.del(table, id);
          break;
        case 'insert':
          memory.insert(table, data);
          break;
        case 'select':
          memory.select(table, params.where);
          break;
        case 'range':
          memory.range(table, params.beg, params.end);
          break;
        case 'update':
          memory.update(table, data);
          break;
        case 'remove':
          memory.remove(table, params.where);
          break;
        case 'make':
          memory.make(table);
          break;
        case 'show':
          memory.show(table);
          break;
        case 'drop':
          memory.drop(table);
          break;
        default:
          Util.error('Store.toMemory() unknown op', op);
      }
    };

    Store.prototype.getMemory = function() {
      this.hasMemory = true;
      if ((Store.Memory != null) && (Store.memories[this.dbName] == null)) {
        Store.memories[this.dbName] = new Store.Memory(this.stream, this.dbName);
      }
      return Store.memories[this.dbName];
    };

    Store.prototype.getMemoryTables = function() {
      return this.getMemory().tables;
    };

    Store.prototype.remember = function() {
      Util.noop(this.getMemory(this.dbName));
    };

    Store.prototype.toSubject = function(table, id, op) {
      var subject;
      if (table == null) {
        table = 'none';
      }
      if (id == null) {
        id = 'none';
      }
      if (op == null) {
        op = 'none';
      }
      subject = "";
      if (table !== 'none') {
        subject += "" + table;
      }
      if (id !== 'none') {
        subject += "/" + id;
      }
      if (op !== 'none') {
        subject += "?op=" + op;
      }
      return subject;
    };

    Store.prototype.toSubjectFromParams = function(params) {
      return this.toSubject(params.table, params.op, params.id);
    };

    Store.prototype.toParams = function(table, id, op, extras, where) {
      var params;
      if (where == null) {
        where = W;
      }
      params = {
        db: this.dbName,
        table: table,
        id: id,
        op: op,
        module: this.module,
        where: where,
        beg: "",
        end: ""
      };
      return Util.copyProperties(params, extras);
    };

    Store.prototype.toStoreObject = function(params, result) {
      return {
        params: params,
        result: result
      };
    };

    Store.prototype.fromStoreObject = function(object) {
      return [object.params, object.result];
    };

    Store.prototype.toSubjects = function(tables, ops, ids) {
      var array, elem, i, j, ref;
      array = [];
      for (i = j = 0, ref = tables.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        elem = {};
        elem.table = tables[i];
        elem.op = Util.isArray(ops) ? ops[i] : ops;
        elem.id = Util.isArray(ids) ? ids[i] : 'none';
        array.push(elem);
      }
      return array;
    };

    Store.prototype.completeSubjects = function(array, completeOp, onComplete) {
      var callback, completeSubject, elem, id, j, len, op, sub, subjects;
      subjects = [];
      for (j = 0, len = array.length; j < len; j++) {
        elem = array[j];
        op = elem.op != null ? elem.op : 'none';
        id = elem.id != null ? elem.id : 'none';
        sub = this.toSubject(elem.table, op, id);
        subjects.push(sub);
      }
      completeSubject = this.dbName + "?module=" + this.module + "&op=" + completeOp;
      callback = typeof onComplete === 'function' ? (function(_this) {
        return function() {
          return onComplete();
        };
      })(this) : true;
      return this.stream.complete(completeSubject, subjects, callback);
    };

    Store.prototype.uponTablesComplete = function(tables, ops, completeOp, onComplete) {
      var subjects;
      subjects = this.toSubjects(tables, ops, 'none');
      this.completeSubjects(subjects, completeOp, onComplete);
    };

    Store.prototype.toKeys = function(object) {
      var key, keys, obj;
      keys = [];
      for (key in object) {
        if (!hasProp.call(object, key)) continue;
        obj = object[key];
        keys.push(key);
      }
      return keys;
    };

    Store.prototype.toJSON = function(obj) {
      if (obj != null) {
        return JSON.stringify(obj);
      } else {
        return '';
      }
    };

    Store.prototype.toObject = function(json) {
      if (json) {
        return JSON.parse(json);
      } else {
        return {};
      }
    };

    Store.prototype.toKeysJson = function(json) {
      return this.toKeys(JSON.parse(json));
    };

    Store.prototype.toObjectsJson = function(json, where) {
      return Util.toObjects(JSON.parse(json), where, this.keyProp);
    };

    Store.prototype.onComplete = function() {
      return Util.log('Store.onComplete()', 'Completed');
    };

    Store.prototype.toExtras = function(status, url, datatype, readyState, error) {
      var extras;
      if (readyState == null) {
        readyState = null;
      }
      if (error == null) {
        error = null;
      }
      extras = {
        status: status,
        url: url,
        datatype: datatype,
        readyState: readyState,
        error: error
      };
      if (readyState != null) {
        extras['readyState'] = readyState;
      }
      if (error != null) {
        extras['error'] = error;
      }
      return extras;
    };

    Store.prototype.dataType = function() {
      var parse;
      parse = Util.parseURI(this.uri);
      if (parse.hostname === 'localhost') {
        return 'json';
      } else {
        return 'jsonp';
      }
    };

    Store.nameDb = function(uri) {
      return Util.parseURI(uri).dbName;
    };

    Store.requireStore = function(module) {
      var e;
      Store = null;
      try {
        Store = require('js/store/' + module);
      } catch (error1) {
        e = error1;
        Util.error('Store.requireStore( stream, uri, module) can not find Store module for', module);
      }
      return Store;
    };

    Store.createStore = function(stream, uri, module) {
      var Klazz, store;
      store = null;
      Klazz = Store.requireStore(module);
      if (Klazz != null) {
        store = new Klass(stream, uri, module);
      }
      return store;
    };

    return Store;

  })();

}).call(this);
