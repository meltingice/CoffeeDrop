require 'socket'

class TcpListen

	def initialize()
		@listen = RubyDrop.config['tcp_listen_ip'] || '127.0.0.1'
		@port = RubyDrop.config['tcp_listen_port'] || 11311
		
		@log = Logger.new('log/tcp.log', 10, 10240000);
		if RubyDrop.config['tcp_debug'] then
			@log.level = Logger::DEBUG
		else
			@log.level = Logger::WARN
		end
		
		@log.info("Initializing TCP server on #{@listen}:#{@port}")
		@server = TCPServer.open(@listen, @port)
	end
	
	def start()
		@log.info("Starting TCP server")
		
		loop {
			Thread.start(@server.accept) do |client|
				@log.info("Client connected!")
				client.puts Time.now.ctime
				client.puts "Welcome to RubyDrop"
				
				while line = client.gets
					entry = line.split
					cmd = entry.shift
					
					case cmd
						# Retrieve config value
						when "config_get" then client.puts(RubyDrop.config[entry[0]] || "ERROR")
						
						# Halt the server
						when "stop" then
							client.puts "RubyDrop daemon halting!"
							@log.info("RubyDrop daemon halting!")
							exit(0)
						
						# Disconnect the client
						when "quit" then
							client.puts "Goodbye!"
							client.close
						else
							client.puts "INVALID"
					end
				end
			end
		}
	end

end