(function() {
  var Log;
  var __slice = Array.prototype.slice;
  require('colors');
  Log = (function() {
    function Log() {}
    Log.debug = function() {
      var data;
      data = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      data.unshift("DEBUG:".green.bold);
      return console.log.apply(null, data);
    };
    Log.error = function() {
      var data;
      data = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      data.unshift("ERROR:".red.bold);
      return console.error.apply(null, data);
    };
    Log.info = function() {
      var data;
      data = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      data.unshift("INFO:".blue.bold);
      return console.info.apply(null, data);
    };
    return Log;
  })();
  exports.Log = Log;
}).call(this);
