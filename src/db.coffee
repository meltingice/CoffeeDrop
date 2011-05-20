sqlite = require('sqlite')

class DB
	constructor: ->
		@db = new sqlite.Database()
		