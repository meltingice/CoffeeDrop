cli     = require('cli').enable('version')
daemon  = require('daemon')

Config  = require('./config').Config
Watcher = require('./watcher').Watcher

class CoffeeDrop
  @run: ->
    # Parse the command-line arguments
    args = cli.parse({
      config: ["c", "Path to the config file", "path", "./config.json"]
      daemon: ["d", "Run CoffeeDrop as a daemon"]
      log:    ["l", "Log debugging commands to file", "path", "./log/debug.log"]
    }, ["start", "stop", "restart"])
    
    new CoffeeDrop(args, cli.command)

  constructor: (args, command) ->
    # Load the config
    @config = Config.parse(args.config)
    process.exit(1) if not @config?
    
    if args.daemon?
      console.log "DAEMON!"
    else
      @start()
      
  start: ->
    watcher = new Watcher(@config.watchFolder)
    watcher.start()
    
exports.CoffeeDrop = CoffeeDrop