require "FileUtils"
require "yaml"
require_relative "FSWatcher/filesystemwatcher"

class RubyDrop
	
	def initialize()
		# Load the config
		@config = YAML.load_file("config.yml")
		
		@config['rubydrop_root'] = File.expand_path(@config['rubydrop_root'])
		
		# Check to make sure the root directory exists
		if !File.directory? @config['rubydrop_root'] then
			# If not, create it
		   FileUtils.mkdir_p @config['rubydrop_root']
		end
		
		# Create the filesystem watcher
		@watcher = FileSystemWatcher.new()
		@watcher.addDirectory(@config['rubydrop_root'])
	end
	
	def run()
		@watcher.start do |status, file|
			if (status == FileSystemWatcher::CREATED) then
				puts "created: #{file}"
			elsif (status == FileSystemWatcher::MODIFIED) then
				puts "modified: #{file}"
			elsif (status == FileSystemWatcher::DELETED) then
				puts "deleted: #{file}"
			else
				puts "something happened..."
			end
		end
		
		@watcher.join()
	end
	
end