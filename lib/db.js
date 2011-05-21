(function() {
  var DB, Log, sqlite;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  sqlite = require('sqlite');
  Log = require('./log').Log;
  DB = (function() {
    DB.create = ["CREATE TABLE files (      `id` INTEGER PRIMARY KEY AUTOINCREMENT,       `file` VARCHAR(200) NOT NULL,      `hash` VARCHAR(120) NOT NULL,      UNIQUE (`file`)    );"];
    function DB(folder) {
      this.dbfile = "" + folder + "/.coffeedrop/coffeedrop.db";
      this.db = new sqlite.Database();
    }
    DB.prototype.use = function(cb) {
      return this.db.open(this.dbfile, function(err) {
        if (err) {
          return Log.error(err);
        } else {
          return cb();
        }
      });
    };
    DB.prototype.query = function(sql, cb) {
      return this.use(__bind(function() {
        return this.db.execute(sql, function(err, rows) {
          if (err != null) {
            Log.error(err);
          }
          return cb(rows);
        });
      }, this));
    };
    DB.prototype.setup = function(done) {
      return this.use(__bind(function() {
        var finished, query, _i, _len, _ref, _results;
        finished = 0;
        _ref = DB.create;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          query = _ref[_i];
          _results.push(this.db.execute(query, function(err, rows) {
            if (err != null) {
              Log.error(err);
            }
            finished++;
            if (finished === DB.create.length) {
              return done();
            }
          }));
        }
        return _results;
      }, this));
    };
    return DB;
  })();
  exports.DB = DB;
}).call(this);
