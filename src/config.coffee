fs  = require('fs')
Log = require('./log').Log

class Config
  @parse: (path) ->
    Log.debug "Reading config from #{path}"
    
    try
      contents = fs.readFileSync(path, "utf-8")
      config = JSON.parse(contents)
      
      # Convert ~ to the user's home directory automatically
      config.watchFolder = config.watchFolder.replace("~", process.env.HOME)
    catch error
      Log.error "Unable to read and/or find config file"
      return null
      
    config
    
exports.Config = Config