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

    Fire.OnFire = {
      get: "value",
      add: "child_added",
      put: "child_changed",
      del: "child_removed"
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
            return _this.publish(tableName, 'add', id, object);
          } else {
            return _this.onError(tableName, 'add', id, object, {
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
          if ((snapshot != null) && (snapshot.val() != null)) {
            return _this.publish(tableName, 'get', id, snapshot.val());
          } else {
            return _this.onError(tableName, 'get', id, {
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
            return _this.publish(tableName, 'put', id, object);
          } else {
            return _this.onError(tableName, 'put', id, object, {
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
            return _this.publish(tableName, 'del', id, {});
          } else {
            return _this.onError(tableName, 'del', id, {}, {
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
            return _this.publish(tableName, 'insert', 'none', objects);
          } else {
            return _this.onError(tableName, 'insert', 'none', {
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
          if ((snapshot != null) && (snapshot.val() != null)) {
            return _this.publish(tableName, 'select', 'none', snapshot.val());
          } else {
            return _this.publish(tableName, 'select', 'none', {});
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
            return _this.publish(tableName, 'range', 'none', val);
          } else {
            return _this.publish(tableName, 'range', 'none', {});
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
            return _this.publish(tableName, 'update', 'none', objects);
          } else {
            return _this.onError(tableName, 'update', 'none', {
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
      this.publish(tableName, 'remove', 'none', keys);
    };

    Fire.prototype.make = function(t) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'make', 'none', {}, {});
          } else {
            return _this.onError(tableName, 'make', 'none', {}, {
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
            return _this.publish(tableName, 'show', 'none', keys, {
              where: where.toString()
            });
          } else {
            return _this.onError(tableName, 'show', 'none', {}, {
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
            return _this.publish(tableName, 'drop', 'none', "OK");
          } else {
            return _this.onError(tableName, 'drop', 'none', {}, {
              error: error
            });
          }
        };
      })(this);
      this.fd.ref(tableName).remove(onComplete);
    };

    Fire.prototype.on = function(t, onEvt, id, onFunc) {
      var onComplete, path, table;
      if (id == null) {
        id = 'none';
      }
      if (onFunc == null) {
        onFunc = null;
      }
      table = this.tableName(t);
      onComplete = (function(_this) {
        return function(snapshot) {
          var key, val;
          if (snapshot != null) {
            key = snapshot.key;
            val = _this.toObjects(snapshot.val());
            if (onFunc != null) {
              return onFunc(key, val);
            } else {
              return _this.publish(table, onEvt, key, val);
            }
          } else {
            return _this.onError(table, onEvt, id, {}, {
              error: 'error'
            });
          }
        };
      })(this);
      path = id === 'none' ? table : table + '/' + id;
      this.fd.ref(path).on(Fire.OnFire[onEvt], onComplete);
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
