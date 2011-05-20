(function() {
  var Log, Watcher, fs;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  fs = require('fs');
  Log = require('./log').Log;
  Watcher = (function() {
    function Watcher(folder) {
      this.folder = folder;
      this.files = {};
      try {
        fs.statSync(this.folder);
      } catch (error) {
        Log.debug("Created " + this.folder);
        fs.mkdirSync(this.folder, 0775);
      }
    }
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
      var file, stats, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        file = "" + path + "/" + file;
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
