(function() {
  var DB, Log, Watcher, fs;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  fs = require('fs');
  Log = require('./log').Log;
  DB = require('./db').DB;
  Watcher = (function() {
    function Watcher(folder) {
      this.folder = folder;
      this.db = new DB(folder);
      try {
        fs.statSync(this.folder);
        this.start();
      } catch (error) {
        Log.debug("Created " + this.folder);
        this.initialize();
      }
    }
    Watcher.prototype.initialize = function() {
      fs.mkdirSync(this.folder, 0775);
      fs.mkdirSync("" + this.folder + "/.coffeedrop", 0775);
      return this.db.setup(__bind(function() {
        return Log.debug("SQLite database initialized");
      }, this));
    };
    Watcher.prototype.start = function() {
      return this.fileScan(this.folder, false);
    };
    Watcher.prototype.fileScan = function(path, async) {
      var files;
      if (async == null) {
        async = true;
      }
      if (async) {
        return fs.readdir(path, __bind(function(err, files) {
          return this.processFiles(true, path, files);
        }, this));
      } else {
        files = fs.readdirSync(path);
        return this.processFiles(false, path, files);
      }
    };
    Watcher.prototype.processFiles = function(async, path, files) {
      var file, filename, stats, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        filename = files[_i];
        if (filename.substr(0, 1) !== ".") {
          continue;
        }
        file = "" + path + "/" + filename;
        _results.push(async ? fs.stat(file, __bind(function(err, stats) {
          if (stats.isDirectory()) {
            return this.fileScan(file, true);
          } else {
            Log.info("Started tracking " + file);
            return this.files[file] = false;
          }
        }, this)) : (stats = fs.statSync(file), stats.isDirectory() ? this.fileScan(file, false) : (Log.info("Started tracking " + file), this.files[file] = false)));
      }
      return _results;
    };
    return Watcher;
  })();
  exports.Watcher = Watcher;
}).call(this);
