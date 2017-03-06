// Generated by CoffeeScript 1.12.2
(function() {
  var $, Rest, Store,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Store = require('js/store/Store');

  $ = require('jquery');

  Rest = (function(superClass) {
    extend(Rest, superClass);

    module.exports = Rest;

    function Rest(stream, uri, db) {
      Rest.__super__.constructor.call(this, stream, uri, 'Rest');
      this.W = Store.where;
      this.S = Store.schema;
      this.A = Store.alters;
      this.R = Store.resets;
    }

    Rest.prototype.add = function(table, id, object, params) {
      if (params == null) {
        params = "";
      }
      return this.ajaxRest('add', table, id, object, params);
    };

    Rest.prototype.get = function(table, id, params) {
      if (params == null) {
        params = "";
      }
      return this.ajaxRest('get', table, id, params);
    };

    Rest.prototype.put = function(table, id, object, params) {
      if (params == null) {
        params = "";
      }
      return this.ajaxRest('put', table, id, object, params);
    };

    Rest.prototype.del = function(table, id, params) {
      if (params == null) {
        params = "";
      }
      return this.ajaxRest('del', table, id, params);
    };

    Rest.prototype.insert = function(table, objects, params) {
      if (params == null) {
        params = "";
      }
      return this.ajaxSql('insert', table, this.W, objects, params);
    };

    Rest.prototype.select = function(table, where, params) {
      if (where == null) {
        where = this.W;
      }
      if (params == null) {
        params = "";
      }
      return this.ajaxSql('select', table, where, null, params);
    };

    Rest.prototype.update = function(table, objects, params) {
      if (params == null) {
        params = "";
      }
      return this.ajaxSql('update', table, this.W, objects, params);
    };

    Rest.prototype.remove = function(table, where, params) {
      if (where == null) {
        where = this.W;
      }
      if (params == null) {
        params = "";
      }
      return this.ajaxSql('remove', table, where, null, params);
    };

    Rest.prototype.open = function(table, schema) {
      if (schema == null) {
        schema = this.S;
      }
      return this.ajaxTable('open', table, {
        schema: schema
      });
    };

    Rest.prototype.show = function(table, format) {
      if (format == null) {
        format = this.F;
      }
      return this.ajaxTable('show', table, {
        format: format
      });
    };

    Rest.prototype.make = function(table, alters) {
      if (alters == null) {
        alters = this.A;
      }
      return this.ajaxTable('make', table, {
        alters: alters
      });
    };

    Rest.prototype.drop = function(table, resets) {
      if (resets == null) {
        resets = this.R;
      }
      return this.ajaxTable('drop', table, {
        resets: resets
      });
    };

    Rest.prototype.onChange = function(t, id) {
      if (id == null) {
        id = 'none';
      }
      this.onerror(t, id, 'onChange', {}, {
        msg: "onChange() not implemeted by Store.Rest"
      });
    };

    Rest.prototype.ajaxRest = function(op, t, id, object, params) {
      var dataType, settings, tableName, url;
      if (object == null) {
        object = null;
      }
      if (params == null) {
        params = "";
      }
      tableName = this.tableName(t);
      url = this.urlRest(op, t, '', params);
      dataType = this.dataType();
      settings = {
        url: url,
        type: this.restOp(op),
        dataType: dataType,
        processData: false,
        contentType: 'application/json',
        accepts: 'application/json'
      };
      if (object != null) {
        settings.data = this.toJSON(object);
      }
      settings.success = (function(_this) {
        return function(data, status, jqXHR) {
          var extras, result;
          result = {};
          if (op === 'get') {
            result = _this.toObject(data);
          }
          if (op === 'add' || op === 'put') {
            result = object;
          }
          extras = _this.toExtras(status, url, dataType, jqXHR.readyState);
          return _this.publish(tableName, id, op, result, extras);
        };
      })(this);
      settings.error = (function(_this) {
        return function(jqXHR, status, error) {
          var extras, result;
          result = {};
          if (op === 'add' || op === 'put') {
            result = object;
          }
          extras = _this.toExtras(status, url, dataType, jqXHR.readyState, error);
          return _this.onerror(tableName, id, op, result, extras);
        };
      })(this);
      $.ajax(settings);
    };

    Rest.prototype.ajaxSql = function(op, t, where, objects, params) {
      var dataType, settings, tableName, url;
      if (objects == null) {
        objects = null;
      }
      if (params == null) {
        params = "";
      }
      tableName = this.tableName(t);
      url = this.urlRest(op, t, '', params);
      dataType = this.dataType();
      settings = {
        url: url,
        type: this.restOp(op),
        dataType: dataType,
        processData: false,
        contentType: 'application/json',
        accepts: 'application/json'
      };
      if (objects != null) {
        settings.data = objects;
      }
      settings.success = (function(_this) {
        return function(data, status, jqXHR) {
          var extras, result;
          result = {};
          if ((data != null) && (op === 'select' || op === 'remove')) {
            result = Util.toObjects(data, where, _this.key);
          }
          if ((objects != null) && (op === 'insert' || op === 'update')) {
            result = objects;
          }
          extras = _this.toExtras(status, url, dataType, jqXHR.readyState);
          if (op === 'select' || op === 'delete') {
            extras.where = 'all';
          }
          return _this.publish(tableName, 'none', op, result, extras);
        };
      })(this);
      settings.error = (function(_this) {
        return function(jqXHR, status, error) {
          var extras, result;
          result = {};
          if (op === 'open' || op === 'update') {
            result = objects;
          }
          extras = _this.toExtras(status, url, dataType, jqXHR.readyState, error);
          if (op === 'select' || op === 'delete') {
            extras.where = 'all';
          }
          return _this.onerror(tableName, 'none', op, result, extras);
        };
      })(this);
      $.ajax(settings);
    };

    Rest.prototype.ajaxTable = function(op, t, options) {
      var dataType, settings, tableName, url;
      tableName = this.tableName(t);
      url = this.urlRest(op, t, '');
      dataType = this.dataType();
      settings = {
        url: url,
        type: this.restOp(op),
        dataType: dataType,
        processData: false,
        contentType: 'application/json',
        accepts: 'application/json'
      };
      settings.success = (function(_this) {
        return function(data, status, jqXHR) {
          var extras, result;
          result = op === 'show' ? _this.toKeysJson(data) : {};
          extras = _this.toExtras(status, url, dataType, jqXHR.readyState);
          return _this.publish(tableName, 'none', op, result, _this.copyProperties(extras, options));
        };
      })(this);
      settings.error = (function(_this) {
        return function(jqXHR, status, error) {
          var extras;
          extras = _this.toExtras(status, url, dataType, jqXHR.readyState, error);
          return _this.onerror(tableName, 'none', op, {}, _this.copyProperties(extras, options));
        };
      })(this);
      $.ajax(settings);
    };

    Rest.prototype.urlRest = function(op, table, id, params) {
      var tableJson;
      if (id == null) {
        id = '';
      }
      if (params == null) {
        params = '';
      }
      tableJson = table + '.json';
      switch (op) {
        case 'add':
        case 'get':
        case 'put':
        case 'del':
          return this.uri + '/' + tableJson + '/' + id + params;
        case 'insert':
        case 'select':
        case 'update':
        case 'remove':
          return this.uri + '/' + tableJson + params;
        case 'open':
        case 'show':
        case 'make':
        case 'drop':
          return this.uri + '/' + tableJson;
        case 'onChange':
          if (id === '') {
            return this.uri + '/' + table;
          } else {
            return this.uri + '/' + tableJson + '/' + id + params;
          }
          break;
        default:
          Util.error('Store.Rest.urlRest() Unknown op', op);
          return this.uri + '/' + tableJson;
      }
    };

    Rest.prototype.restOp = function(op) {
      switch (op) {
        case 'add':
        case 'insert':
        case 'open':
          return 'post';
        case 'get':
        case 'select':
        case 'show':
          return 'get';
        case 'put':
        case 'update':
        case 'make':
          return 'put';
        case 'del':
        case 'remove':
        case 'drop':
          return 'delete';
        case 'onChange':
          return 'get';
        default:
          Util.error('Store.Rest.restOp() Unknown op', op);
          return 'get';
      }
    };

    return Rest;

  })(Store);

}).call(this);
