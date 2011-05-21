fs  = require('fs')

{Log} = require('./log')
{DB}  = require('./db')

class Watcher
  constructor: (folder) ->
    @folder = folder
    @db = new DB(folder)
    
    try
      fs.statSync(@folder)
      @start()
    catch error
      Log.debug "Created #{@folder}"
      @initialize()
  
  # Setup the operating environment
  initialize: ->
    fs.mkdirSync(@folder, 0775)
    fs.mkdirSync("#{@folder}/.coffeedrop", 0775)
    
    @db.setup =>
      Log.debug "SQLite database initialized"
      #@start()
    
  start: ->
    @fileScan(@folder, false)
    
  fileScan: (path, async = true) ->
    if async
      fs.readdir(path, (err, files) =>
        @processFiles(true, path, files)
      )
    else
      files = fs.readdirSync(path)
      @processFiles(false, path, files)

  processFiles: (async, path, files) ->
    for filename in files
      # Skip hidden dirs
      continue if filename.substr(0, 1) != "."
      
      file = "#{path}/#{filename}"
      
      if async
        fs.stat(file, (err, stats) =>
          if stats.isDirectory()
            @fileScan(file, true)
          else
            Log.info "Started tracking #{file}"
            @files[file] = false
        )
      else
        stats = fs.statSync(file)
        if stats.isDirectory()
          @fileScan(file, false)
        else
          Log.info "Started tracking #{file}"
          @files[file] = false
          
exports.Watcher = Watcher