require('colors')

class Log
	@debug: (data...) ->
		data.unshift("DEBUG:".green.bold)
		console.log.apply(null, data)
		
	@error: (data...) ->
		data.unshift("ERROR:".red.bold);
		console.error.apply(null, data)
		
	@info: (data...) ->
		data.unshift("INFO:".blue.bold);
		console.info.apply(null, data)
		
exports.Log = Log