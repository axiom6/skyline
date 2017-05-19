// Generated by CoffeeScript 1.12.2
(function() {
  var Fire, Store,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Store = require('js/store/Store');

  Store.Firebase = firebase;

  Fire = (function(superClass) {
    extend(Fire, superClass);

    module.exports = Fire;

    Fire.EventOn = {
      value: "onVal",
      child_added: "onAdd",
      child_changed: "onPut",
      child_removed: "onDel",
      child_moved: "onMov"
    };

    Fire.OnEvent = {
      onVal: "value",
      onAdd: "child_added",
      onPut: "child_changed",
      onDel: "child_removed",
      onMov: "child_moved"
    };

    function Fire(stream, uri, config1) {
      this.config = config1;
      Fire.__super__.constructor.call(this, stream, uri, 'Fire');
      this.fb = this.init(this.config);
      this.auth();
      this.fd = Store.Firebase.database();
    }

    Fire.prototype.init = function(config) {
      Store.Firebase.initializeApp(config);
      return Store.Firebase;
    };

    Fire.prototype.add = function(t, id, object) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      object[this.keyProp] = id;
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, id, 'add', object);
          } else {
            return _this.onError(tableName, id, 'add', object, {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName + '/' + id).set(object, onComplete);
    };

    Fire.prototype.get = function(t, id) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(snapshot) {
          var object;
          if ((snapshot != null) && (snapshot.val() != null)) {
            object = snapshot.val();
            object[_this.keyProp] = id;
            return _this.publish(tableName, id, 'get', object);
          } else {
            return _this.onError(tableName, id, 'get', {
              msg: 'Fire get error'
            });
          }
        };
      })(this);
      this.fd.ref(tableName + '/' + id).once('value', onComplete);
    };

    Fire.prototype.put = function(t, id, object) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      object[this.keyProp] = id;
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            object[_this.keyProp] = id;
            return _this.publish(tableName, id, 'put', object);
          } else {
            return _this.onError(tableName, id, 'put', object, {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName + '/' + id).set(object, onComplete);
    };

    Fire.prototype.del = function(t, id) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, id, 'del', {});
          } else {
            return _this.onError(tableName, id, 'del', {}, {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName + '/' + id).remove(onComplete);
    };

    Fire.prototype.insert = function(t, objects) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'insert', objects);
          } else {
            return _this.onError(tableName, 'none', 'insert', {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName).set(objects, onComplete);
    };

    Fire.prototype.select = function(t, where) {
      var onComplete, tableName;
      if (where == null) {
        where = Store.where;
      }
      Util.noop(where);
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(snapshot) {
          var val;
          if ((snapshot != null) && (snapshot.val() != null)) {
            val = _this.toObjects(snapshot.val());
            return _this.publish(tableName, 'none', 'select', val);
          } else {
            return _this.publish(tableName, 'none', 'select', {});
          }
        };
      })(this);
      this.fd.ref(tableName).once('value', onComplete);
    };

    Fire.prototype.range = function(t, beg, end) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(snapshot) {
          var val;
          if ((snapshot != null) && (snapshot.val() != null)) {
            val = _this.toObjects(snapshot.val());
            return _this.publish(tableName, 'none', 'range', val);
          } else {
            return _this.publish(tableName, 'none', 'range', {});
          }
        };
      })(this);
      this.fd.ref(tableName).orderByKey().startAt(beg).endAt(end).once('value', onComplete);
    };

    Fire.prototype.update = function(t, objects) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'update', objects);
          } else {
            return _this.onError(tableName, 'none', 'update', {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName).update(objects, onComplete);
    };

    Fire.prototype.remove = function(t, keys) {
      var i, key, len, ref, tableName;
      tableName = this.tableName(t);
      ref = this.fd.ref(t);
      for (i = 0, len = keys.length; i < len; i++) {
        key = keys[i];
        ref.child(key).remove();
      }
      this.publish(tableName, 'none', 'remove', keys);
    };

    Fire.prototype.make = function(t) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'make', {}, {});
          } else {
            return _this.onError(tableName, 'none', 'make', {}, {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref().set(tableName, onComplete);
    };

    Fire.prototype.show = function(t, where) {
      var onComplete, tableName;
      if (where == null) {
        where = Store.where;
      }
      tableName = t != null ? this.tableName(t) : this.dbName;
      onComplete = (function(_this) {
        return function(snapshot) {
          var keys;
          if ((snapshot != null) && (snapshot.val() != null)) {
            keys = Util.toKeys(snapshot.val(), where, _this.keyProp);
            return _this.publish(tableName, 'none', 'show', keys, {
              where: where.toString()
            });
          } else {
            return _this.onError(tableName, 'none', 'show', {}, {
              where: where.toString()
            });
          }
        };
      })(this);
      if (t != null) {
        this.fd.ref(tableName).once('value', onComplete);
      } else {
        this.fd.ref().once('value', onComplete);
      }
    };

    Fire.prototype.drop = function(t) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'drop', "OK");
          } else {
            return _this.onError(tableName, 'none', 'drop', {}, {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName).remove(onComplete);
    };

    Fire.prototype.on = function(t, onEvt, id) {
      var onComplete, path, table;
      if (id == null) {
        id = 'none';
      }
      table = this.tableName(t);
      onComplete = (function(_this) {
        return function(snapshot) {
          var key, val;
          if (snapshot != null) {
            key = snapshot.key;
            val = _this.toObjects(snapshot.val());
            return _this.publish(table, id, onEvt, {
              onEvt: onEvt,
              table: table,
              key: key,
              val: val
            });
          } else {
            return _this.onError(table, id, onEvt, {}, {
              error: 'error'
            });
          }
        };
      })(this);
      path = id === 'none' ? table : table + '/' + id;
      this.fd.ref(path).on(Fire.OnEvent[onEvt], onComplete);
    };

    Fire.prototype.toObjects = function(rows) {
      var ckey, i, len, objects, row;
      objects = {};
      if (Util.isArray(rows)) {
        for (i = 0, len = rows.length; i < len; i++) {
          row = rows[i];
          if ((row != null) && (row['key'] != null)) {
            ckey = row['key'].split('/')[0];
            objects[row[ckey]] = this.toObjects(row);
            Util.log('Fire.toObjects', {
              rkowKey: row['key'],
              ckey: ckey,
              row: row
            });
          } else {
            Util.error("Fire.toObjects() row array element requires key property", row);
          }
        }
      } else {
        objects = rows;
      }
      return objects;
    };

    Fire.prototype.auth = function() {
      var onerror;
      onerror = (function(_this) {
        return function(error) {
          return _this.onError('none', 'none', 'anon', {}, {
            error: error
          });
        };
      })(this);
      this.fb.auth().signInAnonymously()["catch"](onerror);
    };

    return Fire;

  })(Store);

}).call(this);
