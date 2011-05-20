(function() {
  var CoffeeDrop, Config, Watcher, cli, daemon;
  cli = require('cli').enable('version');
  daemon = require('daemon');
  Config = require('./config').Config;
  Watcher = require('./watcher').Watcher;
  CoffeeDrop = (function() {
    CoffeeDrop.run = function() {
      var args;
      args = cli.parse({
        config: ["c", "Path to the config file", "path", "./config.json"],
        daemon: ["d", "Run CoffeeDrop as a daemon"],
        log: ["l", "Log debugging commands to file", "path", "./log/debug.log"]
      }, ["start", "stop", "restart"]);
      return new CoffeeDrop(args, cli.command);
    };
    function CoffeeDrop(args, command) {
      this.config = Config.parse(args.config);
      if (!(this.config != null)) {
        process.exit(1);
      }
      if (args.daemon != null) {
        console.log("DAEMON!");
      } else {
        this.start();
      }
    }
    CoffeeDrop.prototype.start = function() {
      var watcher;
      watcher = new Watcher(this.config.watchFolder);
      return watcher.start();
    };
    return CoffeeDrop;
  })();
  exports.CoffeeDrop = CoffeeDrop;
}).call(this);
