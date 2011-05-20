fs  = require('fs')

Log = require('./log').Log

class Watcher
  constructor: (folder) ->
    @folder = folder
    
    # We use an object instead of an array so that we can
    # quickly reference each file to see if they're being
    # tracked yet.
    @files = {}
    
    try
      fs.statSync(@folder)
    catch error
      Log.debug "Created #{@folder}"
      fs.mkdirSync(@folder, 0775)
    
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
    for file in files
      file = "#{path}/#{file}"
      
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