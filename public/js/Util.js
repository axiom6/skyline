// Generated by CoffeeScript 1.12.2
var Util,
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

Util = (function() {
  function Util() {}

  Util.myVar = 'myVar';

  Util.skipReady = false;

  Util.isCommonJS = false;

  Util.isWebPack = false;

  if (typeof module === "object" && typeof module.exports === "object") {
    Util.isCommonJS = true;
  } else {
    Util.isWebPack = true;
  }

  Util.Load = null;

  Util.ModuleGlobals = [];

  Util.app = {};

  Util.testTrue = true;

  Util.debug = false;

  Util.message = false;

  Util.count = 0;

  Util.modules = [];

  Util.instances = [];

  Util.globalPaths = [];

  Util.root = '../';

  Util.rootJS = Util.root + 'js/';

  Util.databases = {};

  Util.htmlIds = {};

  Util.logStackNum = 0;

  Util.logStackMax = 100;

  Util.fills = {};

  Util.init = function(moduleCommonJS, moduleWebPack, root, prj) {
    if (moduleCommonJS == null) {
      moduleCommonJS = void 0;
    }
    if (moduleWebPack == null) {
      moduleWebPack = void 0;
    }
    if (root == null) {
      root = Util.root;
    }
    if (prj == null) {
      prj = "ui";
    }
    Util.root = root;
    Util.rootJS = Util.root + 'js/';
    Util.resetModuleExports(prj);
    Util.fixTestGlobals();
    if (Util.isCommonJS && (moduleCommonJS != null)) {
      require(moduleCommonJS);
    } else if (Util.isWebPack && (moduleWebPack != null)) {
      Util.skipReady = true;
      Util.loadScript(moduleWebPack);
    } else {
      Util.error("Bad arguments for Util.init() isCommonJS=" + Util.isCommonJS + ",\nroot=" + root + ", moduleCommonJS=" + (moduleCommonJS != null) + ", moduleWebPack=" + moduleWebPack);
    }
  };

  Util.requireModule = function(module, prj) {
    if (prj == null) {
      prj = null;
    }
    if (Util[module] != null) {
      return Util[module];
    } else if (Util.isCommonJS) {
      if ((Util.module == null) && (prj != null)) {
        Util.resetModuleExports(prj);
      }
      return require(module);
    } else if (typeof require !== "undefined" && require !== null) {
      return require(module);
    } else if (module === 'jquery' && (window['jQuery'] != null)) {
      return window['jQuery'];
    } else if (window[module] != null) {
      return window[module] != null;
    } else {
      Util.error('Util.requireModule() module not found', module);
      return null;
    }
  };

  Util.initJasime = function() {
    Util.resetModuleExports();
    if (!Util.isCommonJS) {
      window.require = Util.loadScript;
    } else {
      Util.fixTestGlobals();
      window.exports = module.exports;
      window.jasmineRequire = window.exports;
    }
  };

  Util.require = function(path) {
    if (Util.isCommonJS) {
      return require(path);
    } else if (Util.isWebPack) {
      Util.warn('Util.require may not work with WebPack', path);
      return require(path);
    } else {
      return Util.loadScript(path + '.js');
    }
  };

  Util.fixTestGlobals = function() {
    return window.Util = Util;
  };

  Util.loadScript = function(path, fn) {
    var head, script;
    head = document.getElementsByTagName('head')[0];
    script = document.createElement('script');
    script.src = path;
    script.async = false;
    if (Util.isFunc(fn)) {
      script.onload = fn;
    }
    head.appendChild(script);
  };

  Util.resetModuleExports = function(prj) {
    if (Util.isCommonJS) {
      Util.module = require('module');
      Util.module.globalPaths.push("/Users/ax/Documents/prj/" + prj + "/");
    }
  };

  Util.ready = function(fn) {
    if (!Util.isFunc(fn)) {
      return;
    } else if (Util.skipReady) {
      fn();
    } else if (document.readyState === 'complete') {
      fn();
    } else {
      document.addEventListener('DOMContentLoaded', fn, false);
    }
  };

  Util.hasMethod = function(obj, method, issue) {
    var has;
    if (issue == null) {
      issue = false;
    }
    has = typeof obj[method] === 'function';
    if (!has && issue) {
      Util.log('Util.hasMethod()', method, has);
    }
    return has;
  };

  Util.hasGlobal = function(global, issue) {
    var has;
    if (issue == null) {
      issue = true;
    }
    has = window[global] != null;
    if (!has && issue) {
      Util.error("Util.hasGlobal() " + global + " not present");
    }
    return has;
  };

  Util.getGlobal = function(global, issue) {
    if (issue == null) {
      issue = true;
    }
    if (Util.hasGlobal(global, issue)) {
      return window[global];
    } else {
      return null;
    }
  };

  Util.hasPlugin = function(plugin, issue) {
    var glob, has, plug;
    if (issue == null) {
      issue = true;
    }
    glob = Util.firstTok(plugin, '.');
    plug = Util.lastTok(plugin, '.');
    has = (window[glob] != null) && (window[glob][plug] != null);
    if (!has && issue) {
      Util.error("Util.hasPlugin()  $" + (glob + '.' + plug) + " not present");
    }
    return has;
  };

  Util.hasModule = function(path, issue) {
    var has;
    if (issue == null) {
      issue = true;
    }
    has = Util.modules[path] != null;
    if (!has && issue) {
      Util.error("Util.hasModule() " + path + " not present");
    }
    return has;
  };

  Util.dependsOn = function() {
    var arg, has, j, len1, ok;
    ok = true;
    for (j = 0, len1 = arguments.length; j < len1; j++) {
      arg = arguments[j];
      has = Util.hasGlobal(arg, false) || Util.hasModule(arg, false) || Util.hasPlugin(arg, false);
      if (!has) {
        Util.error('Missing Dependency', arg);
      }
      if (has === false) {
        ok = has;
      }
    }
    return ok;
  };

  Util.setInstance = function(instance, path) {
    Util.log('Util.setInstance()', path);
    if ((instance == null) && (path != null)) {
      Util.error('Util.setInstance() instance not defined for path', path);
    } else if ((instance != null) && (path == null)) {
      Util.error('Util.setInstance() path not defined for instance', instance.toString());
    } else {
      Util.instances[path] = instance;
    }
  };

  Util.getInstance = function(path, dbg) {
    var instance;
    if (dbg == null) {
      dbg = false;
    }
    if (dbg) {
      Util.log('getInstance', path);
    }
    instance = Util.instances[path];
    if (instance == null) {
      Util.error('Util.getInstance() instance not defined for path', path);
    }
    return instance;
  };

  Util.toStrArgs = function(prefix, args) {
    var arg, j, len1, str;
    Util.logStackNum = 0;
    str = Util.isStr(prefix) ? prefix + " " : "";
    for (j = 0, len1 = args.length; j < len1; j++) {
      arg = args[j];
      str += Util.toStr(arg) + " ";
    }
    return str;
  };

  Util.toStr = function(arg) {
    Util.logStackNum++;
    if (Util.logStackNum > Util.logStackMax) {
      return '';
    }
    switch (typeof arg) {
      case 'null':
        return 'null';
      case 'string':
        return Util.toStrStr(arg);
      case 'number':
        return arg.toString();
      case 'object':
        return Util.toStrObj(arg);
      default:
        return arg;
    }
  };

  Util.toStrObj = function(arg) {
    var a, j, key, len1, str, val;
    str = "";
    if (arg == null) {
      str += "null";
    } else if (Util.isArray(arg)) {
      str += "[ ";
      for (j = 0, len1 = arg.length; j < len1; j++) {
        a = arg[j];
        str += Util.toStr(a) + ",";
      }
      str = str.substr(0, str.length - 1) + " ]";
    } else if (Util.isObjEmpty(arg)) {
      str += "{}";
    } else {
      str += "{ ";
      for (key in arg) {
        if (!hasProp.call(arg, key)) continue;
        val = arg[key];
        str += key + ":" + Util.toStr(val) + ", ";
      }
      str = str.substr(0, str.length - 2) + " }";
    }
    return str;
  };

  Util.toStrStr = function(arg) {
    if (arg.length > 0) {
      return arg;
    } else {
      return '""';
    }
  };

  Util.noop = function() {
    if (false) {
      Util.log(arguments);
    }
  };

  Util.dbg = function() {
    var str;
    if (!Util.debug) {
      return;
    }
    str = Util.toStrArgs('', arguments);
    Util.consoleLog(str);
  };

  Util.msg = function() {
    var str;
    if (!Util.message) {
      return;
    }
    str = Util.toStrArgs('', arguments);
    Util.consoleLog(str);
  };

  Util.error = function() {
    var str;
    str = Util.toStrArgs('Error:', arguments);
    Util.consoleLog(str);
  };

  Util.warn = function() {
    var str;
    str = Util.toStrArgs('Warning:', arguments);
    Util.consoleLog(str);
  };

  Util.toError = function() {
    var str;
    str = Util.toStrArgs('Error:', arguments);
    return new Error(str);
  };

  Util.log = function() {
    var str;
    str = Util.toStrArgs('', arguments);
    Util.consoleLog(str);
  };

  Util.called = function() {
    var str;
    str = Util.toStrArgs('', arguments);
    Util.consoleLog(str);
  };

  Util.gritter = function() {
    var args, opts, str;
    opts = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    if (!(Util.hasGlobal('$', false) && ($['gritter'] != null))) {
      return;
    }
    str = Util.toStrArgs('', args);
    opts.title = opts.title != null ? opts.title : 'Gritter';
    opts.text = str;
  };

  Util.consoleLog = function(str) {
    if (typeof console !== "undefined" && console !== null) {
      console.log(str);
    }
  };

  Util.trace = function() {
    var error, str;
    str = Util.toStrArgs('Trace:', arguments);
    Util.consoleLog(str);
    try {
      throw new Error(str);
    } catch (error1) {
      error = error1;
      Util.log(error.stack);
    }
  };

  Util.alert = function() {
    var str;
    str = Util.toStrArgs('', arguments);
    Util.consoleLog(str);
    alert(str);
  };

  Util.logJSON = function(json) {
    return Util.consoleLog(json);
  };

  Util.keys = function(o) {
    if (Util.isObj(o)) {
      return Object.keys(o);
    } else {
      return [];
    }
  };

  Util.isDef = function(d) {
    return d != null;
  };

  Util.isNot = function(d) {
    return !Util.isDef(d);
  };

  Util.isStr = function(s) {
    return (s != null) && typeof s === "string" && s.length > 0;
  };

  Util.isNum = function(n) {
    return (n != null) && typeof n === "number" && !isNaN(n);
  };

  Util.isObj = function(o) {
    return (o != null) && typeof o === "object";
  };

  Util.isVal = function(v) {
    return typeof v === "number" || typeof v === "string" || typeof v === "boolean";
  };

  Util.isObjEmpty = function(o) {
    return Util.isObj(o) && Object.getOwnPropertyNames(o).length === 0;
  };

  Util.isFunc = function(f) {
    return (f != null) && typeof f === "function";
  };

  Util.isArray = function(a) {
    return (a != null) && Array.isArray(a) && (a.length != null) && a.length > 0;
  };

  Util.isEvent = function(e) {
    return (e != null) && (e.target != null);
  };

  Util.inIndex = function(a, i) {
    return Util.isArray(a) && 0 <= i && i < a.length;
  };

  Util.inArray = function(a, e) {
    return Util.isArray(a) && a.indexOf(e) > -1;
  };

  Util.inString = function(s, e) {
    return Util.isStr(s) && s.indexOf(e) > -1;
  };

  Util.atLength = function(a, n) {
    return Util.isArray(a) && a.length === n;
  };

  Util.head = function(a) {
    if (Util.isArray(a)) {
      return a[0];
    } else {
      return null;
    }
  };

  Util.tail = function(a) {
    if (Util.isArray(a)) {
      return a[a.length - 1];
    } else {
      return null;
    }
  };

  Util.time = function() {
    return new Date().getTime();
  };

  Util.isStrInteger = function(s) {
    return /^\s*(\+|-)?\d+\s*$/.test(s);
  };

  Util.isStrFloat = function(s) {
    return /^\s*(\+|-)?((\d+(\.\d+)?)|(\.\d+))\s*$/.test(s);
  };

  Util.isStrCurrency = function(s) {
    return /^\s*(\+|-)?((\d+(\.\d\d)?)|(\.\d\d))\s*$/.test(s);
  };

  Util.isEmpty = function($elem) {
    return ($elem != null) && ($elem.length != null) && $elem.length === 0;
  };

  Util.isDefs = function() {
    var arg, j, len1;
    for (j = 0, len1 = arguments.length; j < len1; j++) {
      arg = arguments[j];
      if (arg == null) {
        return false;
      }
    }
    return true;
  };

  Util.copyProperties = function(to, from) {
    var key, val;
    for (key in from) {
      if (!hasProp.call(from, key)) continue;
      val = from[key];
      to[key] = val;
    }
    return to;
  };

  Util.contains = function(array, value) {
    return Util.isArray(array) && array.indexOf(value) !== -1;
  };

  Util.toPosition = function(array) {
    return {
      left: array[0],
      top: array[1],
      width: array[2],
      height: array[3]
    };
  };

  Util.toPositionPc = function(array) {
    return {
      position: 'absolute',
      left: array[0] + '%',
      top: array[1] + '%',
      width: array[2] + '%',
      height: array[3] + '%'
    };
  };

  Util.cssPosition = function($, screen, port, land) {
    var array;
    array = screen.orientation === 'Portrait' ? port : land;
    $.css(Util.toPositionPc(array));
  };

  Util.xyScale = function(prev, next, port, land) {
    var ref, ref1, xn, xp, xs, yn, yp, ys;
    ref = prev.orientation === 'Portrait' ? [port[2], port[3]] : [land[2], land[3]], xp = ref[0], yp = ref[1];
    ref1 = next.orientation === 'Portrait' ? [port[2], port[3]] : [land[2], land[3]], xn = ref1[0], yn = ref1[1];
    xs = next.width * xn / (prev.width * xp);
    ys = next.height * yn / (prev.height * yp);
    return [xs, ys];
  };

  Util.resize = function(callback) {
    window.onresize = function() {
      return setTimeout(callback, 100);
    };
  };

  Util.resizeTimeout = function(callback, timeout) {
    if (timeout == null) {
      timeout = null;
    }
    window.onresize = function() {
      if (timeout != null) {
        clearTimeout(timeout);
      }
      return timeout = setTimeout(callback, 100);
    };
  };

  Util.getHtmlId = function(name, type, ext) {
    if (type == null) {
      type = '';
    }
    if (ext == null) {
      ext = '';
    }
    return name + type + ext;
  };

  Util.htmlId = function(name, type, ext) {
    var id;
    if (type == null) {
      type = '';
    }
    if (ext == null) {
      ext = '';
    }
    id = Util.getHtmlId(name, type, ext);
    if (Util.htmlIds[id] != null) {
      Util.error('Util.htmlId() duplicate html id', id);
    }
    Util.htmlIds[id] = id;
    return id;
  };

  Util.toPage = function(path) {
    return window.location = path;
  };

  Util.extend = function(obj, mixin) {
    var method, name;
    for (name in mixin) {
      if (!hasProp.call(mixin, name)) continue;
      method = mixin[name];
      obj[name] = method;
    }
    return obj;
  };

  Util.include = function(klass, mixin) {
    return Util.extend(klass.prototype, mixin);
  };

  Util.eventErrorCode = function(e) {
    var errorCode;
    errorCode = (e.target != null) && e.target.errorCode ? e.target.errorCode : 'unknown';
    return {
      errorCode: errorCode
    };
  };

  Util.toName = function(s1) {
    var s2, s3, s4;
    s2 = s1.replace('_', ' ');
    s3 = s2.replace(/([A-Z][a-z])/g, ' $1');
    s4 = s3.replace(/([A-Z]+)/g, ' $1');
    return s4;
  };

  Util.toName1 = function(s1) {
    var s2, s3;
    s2 = s1.replace('_', ' ');
    s3 = s2.replace(/([A-Z][a-z])/g, ' $1');
    return s3.substring(1);
  };

  Util.toSelect = function(name) {
    return name.replace(' ', '');
  };

  Util.indent = function(n) {
    var i, j, ref, str;
    str = '';
    for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      str += ' ';
    }
    return str;
  };

  Util.hashCode = function(str) {
    var hash, i, j, ref;
    hash = 0;
    for (i = j = 0, ref = str.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
    }
    return hash;
  };

  Util.lastTok = function(str, delim) {
    return str.split(delim).pop();
  };

  Util.firstTok = function(str, delim) {
    if (Util.isStr(str) && (str.split != null)) {
      return str.split(delim)[0];
    } else {
      Util.error("Util.firstTok() str is not at string", str);
      return '';
    }
  };

  Util.padEnd = function(str, len, ch) {
    var j, pad, ref, ref1;
    if (ch == null) {
      ch = ' ';
    }
    pad = "";
    for (j = ref = str.length, ref1 = len; ref <= ref1 ? j < ref1 : j > ref1; ref <= ref1 ? j++ : j--) {
      pad += ch;
    }
    return str + pad;
  };


  /*
    parse = document.createElement('a')
    parse.href =  "http://example.com:3000/dir1/dir2/file.ext?search=test#hash"
    parse.protocol  "http:"
    parse.hostname  "example.com"
    parse.port      "3000"
    parse.pathname  "/dir1/dir2/file.ext"
    parse.segments  ['dir1','dir2','file.ext']
    parse.fileExt   ['file','ext']
    parse.file       'file'
    parse.ext        'ext'
    parse.search    "?search=test"
    parse.hash      "#hash"
    parse.host      "example.com:3000"
   */

  Util.pdfCSS = function(href) {
    var link;
    if (!window.location.search.match(/pdf/gi)) {
      return;
    }
    link = document.createElement('link');
    link.rel = 'stylesheet';
    link.type = 'text/css';
    link.href = href;
    document.getElementsByTagName('head')[0].appendChild(link);
  };

  Util.parseURI = function(uri) {
    var a, j, len1, name, nameValue, nameValues, parse, ref, value;
    parse = {};
    parse.params = {};
    a = document.createElement('a');
    a.href = uri;
    parse.href = a.href;
    parse.protocol = a.protocol;
    parse.hostname = a.hostname;
    parse.port = a.port;
    parse.segments = a.pathname.split('/');
    parse.fileExt = parse.segments.pop().split('.');
    parse.file = parse.fileExt[0];
    parse.ext = parse.fileExt.length === 2 ? parse.fileExt[1] : '';
    parse.dbName = parse.file;
    parse.fragment = a.hash;
    parse.query = Util.isStr(a.search) ? a.search.substring(1) : '';
    nameValues = parse.query.split('&');
    if (Util.isArray(nameValues)) {
      for (j = 0, len1 = nameValues.length; j < len1; j++) {
        nameValue = nameValues[j];
        ref = nameValue.split('='), name = ref[0], value = ref[1];
        parse.params[name] = value;
      }
    }
    return parse;
  };

  Util.quicksort = function(array, prop, order) {
    var a, head, large, small;
    if (array.length === 0) {
      return [];
    }
    head = array.pop();
    if (order === 'Ascend') {
      small = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = array.length; j < len1; j++) {
          a = array[j];
          if (a[prop] <= head[prop]) {
            results.push(a);
          }
        }
        return results;
      })();
      large = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = array.length; j < len1; j++) {
          a = array[j];
          if (a[prop] > head[prop]) {
            results.push(a);
          }
        }
        return results;
      })();
      return (Util.quicksort(small, prop, order)).concat([head]).concat(Util.quicksort(large, prop, order));
    } else {
      small = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = array.length; j < len1; j++) {
          a = array[j];
          if (a[prop] >= head[prop]) {
            results.push(a);
          }
        }
        return results;
      })();
      large = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = array.length; j < len1; j++) {
          a = array[j];
          if (a[prop] < head[prop]) {
            results.push(a);
          }
        }
        return results;
      })();
      return (Util.quicksort(small, prop, order)).concat([head]).concat(Util.quicksort(large, prop, order));
    }
  };

  Util.quicksortArray = function(array) {
    var a, head, large, small;
    if (array.length === 0) {
      return [];
    }
    head = array.pop();
    small = (function() {
      var j, len1, results;
      results = [];
      for (j = 0, len1 = array.length; j < len1; j++) {
        a = array[j];
        if (a <= head) {
          results.push(a);
        }
      }
      return results;
    })();
    large = (function() {
      var j, len1, results;
      results = [];
      for (j = 0, len1 = array.length; j < len1; j++) {
        a = array[j];
        if (a > head) {
          results.push(a);
        }
      }
      return results;
    })();
    return (Util.quicksort(small)).concat([head]).concat(Util.quicksort(large));
  };

  Util.sortArray = function(array, prop, type, order) {
    var compare;
    compare = function(a, b) {
      if (a[prop] === b[prop]) {
        return 0;
      } else if (a[prop] < b[prop]) {
        return -1;
      } else {
        return 1;
      }
    };
    compare = function(a, b) {
      if (type === 'string' && order === 'Decend') {
        if (a[prop] === b[prop]) {
          return 0;
        } else if (a[prop] < b[prop]) {
          return 1;
        } else {
          return -1;
        }
      }
    };
    compare = function(a, b) {
      if (type === 'number' && order === 'Ascend') {
        return a[prop] - b[prop];
      }
    };
    compare = function(a, b) {
      if (type === 'number' && order === 'Decend') {
        return b[prop] - a[prop];
      }
    };
    return array.sort(compare);
  };

  Util.pad = function(n) {
    if (n < 10) {
      return '0' + n.toString();
    } else {
      return n.toString();
    }
  };

  Util.padStr = function(n) {
    if (n < 10) {
      return '0' + n.toString();
    } else {
      return n.toString();
    }
  };

  Util.isoDateTime = function(dateIn) {
    var date, pad;
    date = dateIn != null ? dateIn : new Date();
    Util.log('Util.isoDatetime()', date);
    Util.log('Util.isoDatetime()', date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes, date.getUTCSeconds);
    pad = function(n) {
      return Util.pad(n);
    };
    return date.getFullYear()(+'-' + pad(date.getUTCMonth() + 1) + '-' + pad(date.getUTCDate()) + 'T' + pad(date.getUTCHours()) + ':' + pad(date.getUTCMinutes()) + ':' + pad(date.getUTCSeconds()) + 'Z');
  };

  Util.toHMS = function(unixTime) {
    var ampm, date, hour, min, sec, time;
    date = Util.isNum(unixTime) ? new Date(unixTime * 1000) : new Date();
    hour = date.getHours();
    ampm = 'AM';
    if (hour > 12) {
      hour = hour - 12;
      ampm = 'PM';
    }
    min = ('0' + date.getMinutes()).slice(-2);
    sec = ('0' + date.getSeconds()).slice(-2);
    time = hour + ":" + min + ":" + sec + " " + ampm;
    return time;
  };

  Util.hex4 = function() {
    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
  };

  Util.hex32 = function() {
    var hex, i, j;
    hex = this.hex4();
    for (i = j = 1; j <= 4; i = ++j) {
      Util.noop(i);
      hex += this.hex4();
    }
    return hex;
  };

  Util.toFixed = function(arg, dec) {
    var num;
    if (dec == null) {
      dec = 2;
    }
    num = (function() {
      switch (typeof arg) {
        case 'number':
          return arg;
        case 'string':
          return parseFloat(arg);
        default:
          return 0;
      }
    })();
    return num.toFixed(dec);
  };

  Util.toInt = function(arg) {
    switch (typeof arg) {
      case 'number':
        return Math.floor(arg);
      case 'string':
        return parseInt(arg);
      default:
        return 0;
    }
  };

  Util.toFloat = function(arg) {
    switch (typeof arg) {
      case 'number':
        return arg;
      case 'string':
        return parseFloat(arg);
      default:
        return 0;
    }
  };

  Util.toCap = function(str) {
    return str.charAt(0).toUpperCase() + str.substring(1);
  };

  Util.unCap = function(str) {
    return str.charAt(0).toLowerCase() + str.substring(1);
  };

  Util.toArray = function(objects, whereIn, keyField) {
    var array, j, key, len1, object, where;
    if (whereIn == null) {
      whereIn = null;
    }
    if (keyField == null) {
      keyField = 'id';
    }
    where = whereIn != null ? whereIn : function() {
      return true;
    };
    array = [];
    if (Util.isArray(objects)) {
      for (j = 0, len1 = array.length; j < len1; j++) {
        object = array[j];
        if (!(where(object))) {
          continue;
        }
        if ((object['id'] != null) && keyField !== 'id') {
          object[keyField] = object['id'];
        }
        array.push(object);
      }
    } else {
      for (key in objects) {
        if (!hasProp.call(objects, key)) continue;
        object = objects[key];
        if (!(where(object))) {
          continue;
        }
        object[keyField] = key;
        array.push(object);
      }
    }
    return array;
  };

  Util.toObjects = function(rows, whereIn, key) {
    var ckey, j, len1, objects, row, where;
    if (whereIn == null) {
      whereIn = null;
    }
    if (key == null) {
      key = 'key';
    }
    where = whereIn != null ? whereIn : function() {
      return true;
    };
    objects = {};
    if (Util.isArray(rows)) {
      for (j = 0, len1 = rows.length; j < len1; j++) {
        row = rows[j];
        if (where(row)) {
          if ((row != null) && (row[key] != null)) {
            ckey = Util.childKey(row[key]);
            objects[row[ckey]] = row;
          } else {
            Util.error("Util.toObjects() row array element requires key property", key, row);
          }
        }
      }
    } else {
      for (key in rows) {
        if (!hasProp.call(rows, key)) continue;
        row = rows[key];
        if (where(row)) {
          objects[key] = row;
        }
      }
    }
    return objects;
  };

  Util.childKey = function(key) {
    return key.split('/')[0];
  };

  Util.toRange = function(rows, beg, end, keyProp) {
    var j, key, len1, objects, row;
    if (keyProp == null) {
      keyProp = 'key';
    }
    objects = {};
    if (Util.isArray(rows)) {
      for (j = 0, len1 = rows.length; j < len1; j++) {
        row = rows[j];
        if (beg <= row[keyProp] && row[keyProp] <= end) {
          objects[row[keyProp]] = row;
        }
      }
    } else {
      for (key in rows) {
        if (!hasProp.call(rows, key)) continue;
        row = rows[key];
        if (beg <= key && key <= end) {
          objects[key] = row;
        }
      }
    }
    return objects;
  };

  Util.toKeys = function(rows, whereIn, keyProp) {
    var j, key, keys, len1, row, where;
    if (whereIn == null) {
      whereIn = null;
    }
    if (keyProp == null) {
      keyProp = 'key';
    }
    where = whereIn != null ? whereIn : function() {
      return true;
    };
    keys = [];
    if (Util.isArray(rows)) {
      for (j = 0, len1 = rows.length; j < len1; j++) {
        row = rows[j];
        if (where(row)) {
          if (row[keyProp] != null) {
            keys.push(row[keyProp]);
          } else {
            Util.error("Util.toKeys() row array element requires key property", keyProp, row);
          }
        }
      }
    } else {
      for (key in rows) {
        if (!hasProp.call(rows, key)) continue;
        row = rows[key];
        if (where(row)) {
          keys.push(key);
        }
      }
    }
    return keys;
  };

  Util.logObjs = function(msg, objects) {
    var key, row;
    Util.log(msg);
    for (key in objects) {
      if (!hasProp.call(objects, key)) continue;
      row = objects[key];
      Util.log('  ', {
        key: key,
        row: row
      });
    }
  };

  Util.match = function(regexp, text) {
    if (regexp[0] === '^') {
      return Util.match_here(regexp.slice(1), text);
    }
    while (text) {
      if (Util.match_here(regexp, text)) {
        return true;
      }
      text = text.slice(1);
    }
    return false;
  };

  Util.match_here = function(regexp, text) {
    var cur, next, ref;
    ref = [regexp[0], regexp[1]], cur = ref[0], next = ref[1];
    if (regexp.length === 0) {
      return true;
    }
    if (next === '*') {
      return Util.match_star(cur, regexp.slice(2), text);
    }
    if (cur === '$' && !next) {
      return text.length === 0;
    }
    if (text && (cur === '.' || cur === text[0])) {
      return Util.match_here(regexp.slice(1), text.slice(1));
    }
    return false;
  };

  Util.match_star = function(c, regexp, text) {
    while (true) {
      if (Util.match_here(regexp, text)) {
        return true;
      }
      if (!(text && (text[0] === c || c === '.'))) {
        return false;
      }
      text = text.slice(1);
    }
  };

  Util.match_test = function() {
    Util.log(Util.match_args("ex", "some text"));
    Util.log(Util.match_args("s..t", "spit"));
    Util.log(Util.match_args("^..t", "buttercup"));
    Util.log(Util.match_args("i..$", "cherries"));
    Util.log(Util.match_args("o*m", "vrooooommm!"));
    return Util.log(Util.match_args("^hel*o$", "hellllllo"));
  };

  Util.match_args = function(regexp, text) {
    return Util.log(regexp, text, Util.match(regexp, text));
  };

  Util.svgId = function(name, type, svgType, check) {
    if (check == null) {
      check = false;
    }
    if (check) {
      return this.id(name, type, svgType);
    } else {
      return name + type + svgType;
    }
  };

  Util.css = function(name, type) {
    if (type == null) {
      type = '';
    }
    return name + type;
  };

  Util.icon = function(name, type, fa) {
    return name + type + ' fa fa-' + fa;
  };

  Util.mineType = function(fileType) {
    var mine;
    mine = (function() {
      switch (fileType) {
        case 'json':
          return "application/json";
        case 'adoc':
          return "text/plain";
        case 'html':
          return "text/html";
        case 'svg':
          return "image/svg+xml";
        default:
          return "text/plain";
      }
    })();
    mine += ";charset=utf-8";
    return mine;
  };

  Util.saveFile = function(stuff, fileName, fileType) {
    var blob, downloadLink, url;
    blob = new Blob([stuff], {
      type: this.mineType(fileType)
    });
    Util.noop(blob);
    url = "";
    downloadLink = document.createElement("a");
    downloadLink.href = url;
    downloadLink.download = fileName;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
  };

  return Util;

})();
