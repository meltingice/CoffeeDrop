(function() {
  var Config, Log, fs;
  fs = require('fs');
  Log = require('./log').Log;
  Config = (function() {
    function Config() {}
    Config.parse = function(path) {
      var config, contents;
      Log.debug("Reading config from " + path);
      try {
        contents = fs.readFileSync(path, "utf-8");
        config = JSON.parse(contents);
        config.watchFolder = config.watchFolder.replace("~", process.env.HOME);
      } catch (error) {
        Log.error("Unable to read and/or find config file");
        return null;
      }
      return config;
    };
    return Config;
  })();
  exports.Config = Config;
}).call(this);
