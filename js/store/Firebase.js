// Generated by CoffeeScript 1.12.2
(function() {
  var Firebase, FirebaseDB, Store,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Store = require('js/store/Store');

  FirebaseDB = require('firebase');

  Firebase = (function(superClass) {
    var FireBaseApiKey, FireBasePassword, FireBaseURL;

    extend(Firebase, superClass);

    module.exports = Firebase;

    FireBaseURL = 'axiom6.firebaseIO.com';

    FireBasePassword = 'Athena66';

    FireBaseApiKey = '';

    function Firebase(stream, uri) {
      Firebase.__super__.constructor.call(this, stream, uri, 'Firebase');
      this.fb = this.openFireBaseDB(uri);
    }

    Firebase.prototype.openFireBaseDB = function(uri) {
      FirebaseDB.initializeApp({
        apiKey: FireBaseApiKey,
        databaseURL: uri
      });
      return FirebaseDB.database().ref();
    };

    Firebase.prototype.add = function(t, id, object) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, id, 'add', object);
          } else {
            return _this.onerror(tableName, id, 'add', object, {
              error: error
            });
          }
        };
      })(this);
      this.fb.child(tableName + '/' + id).set(object, onComplete);
    };

    Firebase.prototype.get = function(t, id) {
      var tableName;
      tableName = this.tableName(t);
      this.fb.child(tableName + '/' + id).once('value', (function(_this) {
        return function(snapshot) {
          if (snapshot.val() != null) {
            return _this.publish(tableName, id, 'get', snapshot.val());
          } else {
            return _this.onerror(tableName, id, 'get', {}, {
              msg: 'Firebase get error'
            });
          }
        };
      })(this));
    };

    Firebase.prototype.put = function(t, id, object) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, id, 'put', object);
          } else {
            return _this.onerror(tableName, id, 'put', object, {
              error: error
            });
          }
        };
      })(this);
      this.fb.child(tableName + '/' + id).update(object, onComplete);
    };

    Firebase.prototype.del = function(t, id) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, id, 'del', {});
          } else {
            return _this.onerror(tableName, id, 'del', {}, {
              error: error
            });
          }
        };
      })(this);
      this.fb.child(tableName).remove(id, onComplete);
    };

    Firebase.prototype.insert = function(t, objects) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'insert', objects);
          } else {
            return _this.onerror(tableName, 'none', 'insert', {
              error: error
            });
          }
        };
      })(this);
      this.fb.child(tableName).set(objects, onComplete);
    };

    Firebase.prototype.select = function(t, where) {
      var tableName;
      if (where == null) {
        where = Store.where;
      }
      tableName = this.tableName(t);
      this.fb.child(tableName).once('value', (function(_this) {
        return function(snapshot) {
          var objects;
          if (snapshot.val() != null) {
            objects = Util.toObjects(snapshot.val(), where, _this.key);
            return _this.publish(tableName, 'none', 'select', objects, {
              where: where.toString()
            });
          } else {
            return _this.onerror(tableName = _this.tableName(t), 'none', 'select', objects, {
              where: where.toString()
            });
          }
        };
      })(this));
    };

    Firebase.prototype.update = function(t, objects) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'insert', objects);
          } else {
            return _this.onerror(tableName, 'none', 'insert', {
              error: error
            });
          }
        };
      })(this);
      this.fb.child(tableName).update(objects, onComplete);
    };

    Firebase.prototype.remove = function(t, where) {
      var tableName;
      if (where == null) {
        where = Store.where;
      }
      tableName = this.tableName(t);
      this.fb.child(t).once('value', (function(_this) {
        return function(snapshot) {
          var key, object, objects;
          if (snapshot.val() != null) {
            objects = Util.toObjects(snapshot.val(), where, _this.key);
            for (key in objects) {
              object = objects[key];
              if (where(val)) {
                _this.fb.child(t).remove(key);
              }
            }
            return _this.publish(tableName, 'none', 'remove', objects, {
              where: where.toString()
            });
          } else {
            return _this.onerror(tableName, 'none', 'remove', objects, {
              where: where.toString()
            });
          }
        };
      })(this));
    };

    Firebase.prototype.open = function(t, schema) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName, 'none', 'open', {}, {
              schema: schema
            });
          } else {
            return _this.onerror(tableName, 'none', 'open', {}, {
              schema: schema,
              error: error
            });
          }
        };
      })(this);
      fb.set(tableName, onComplete);
    };

    Firebase.prototype.show = function(t) {
      var keys, tableName;
      tableName = this.tableName(t);
      keys = [];
      this.fb.once('value', (function(_this) {
        return function(snapshot) {
          return snapshot.forEach(function(table) {
            return keys.push(table.key());
          }, _this.publish(tableName, 'none', 'show', keys));
        };
      })(this));
    };

    Firebase.prototype.make = function(t, alters) {
      var tableName;
      tableName = this.tableName(t);
      this.publish(tableName = this.tableName(t), 'none', 'make', {}, {
        alters: alters
      });
    };

    Firebase.prototype.drop = function(t) {
      var onComplete, tableName;
      tableName = this.tableName(t);
      onComplete = (function(_this) {
        return function(error) {
          if (error == null) {
            return _this.publish(tableName = _this.tableName(t), 'none', 'drop');
          } else {
            return _this.onerror(tableName = _this.tableName(t), 'none', 'drop', {}, {
              error: error
            });
          }
        };
      })(this);
      this.fb.remove(tableName = this.tableName(t), onComplete);
    };

    Firebase.prototype.onChange = function(t, id) {
      var onEvt, path, tableName;
      tableName = this.tableName(t);
      path = id(eq('')) ? tableName : tableName + '/' + id;
      onEvt = 'value';
      this.fb.child(path).on(onEvt, (function(_this) {
        return function(snapshot) {
          var key, val;
          key = snapshot.name();
          val = snapshot.val();
          if ((key != null) && (val != null)) {
            return _this.publish(tableName, id, 'onChange', val, {
              key: key
            });
          } else if (val == null) {
            return _this.publish(tableName, id, 'onChange', {}, {
              key: key,
              msg: 'No Value'
            });
          } else {
            return _this.onerror(tableName, id, 'onChange', {}, {
              error: 'error'
            });
          }
        };
      })(this));
    };

    Firebase.prototype.isNotEvt = function(evt) {
      switch (evt) {
        case 'value':
        case 'child_added':
        case 'child_changed':
        case 'child_removed':
        case 'child_moved':
          return false;
        default:
          return true;
      }
    };

    Firebase.prototype.auth = function(tok) {
      this.fb.auth(tok, (function(_this) {
        return function(error, result) {
          if (error == null) {
            return _this.publish('', tok, 'auth', result.auth, {
              expires: new Date(result.expires * 1000)
            });
          } else {
            return _this.onerror('', tok, 'auth', {}, {
              error: error
            });
          }
        };
      })(this));
    };

    return Firebase;

  })(Store);

}).call(this);
