(function() {
  var DB, sqlite;
  sqlite = require('sqlite');
  DB = (function() {
    function DB() {
      this.db = new sqlite.Database();
    }
    return DB;
  })();
}).call(this);
