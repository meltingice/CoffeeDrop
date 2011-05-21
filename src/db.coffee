sqlite  = require('sqlite')
{Log}   = require('./log')

class DB
  # Table creation queries
  @create = [
    "CREATE TABLE files (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
      `file` VARCHAR(200) NOT NULL,
      `hash` VARCHAR(120) NOT NULL,
      UNIQUE (`file`)
    );"
  ]
  
  constructor: (folder) ->
    @dbfile = "#{folder}/.coffeedrop/coffeedrop.db"
    @db = new sqlite.Database()

  use: (cb) ->
    @db.open @dbfile, (err) ->
      if err then Log.error err else cb()
      
  query: (sql, cb) ->
    @use => @db.execute sql, (err, rows) ->
      Log.error err if err?
      cb(rows) if cb?
      
  setup: (done) ->
    @use =>
      finished = 0
      for query in DB.create
        @db.execute query, (err, rows) ->
          Log.error err if err?
          finished++
          
          done() if finished == DB.create.length
          
exports.DB = DB