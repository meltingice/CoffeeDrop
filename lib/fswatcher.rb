require 'rubygems'
require 'grit'
require 'logger'

include Grit

class FSWatcher

	attr_accessor :run

	def initialize(options = {})
		
		@interval = options[:interval] || 5
		@run = options[:run] || true
	
		# Check to make sure the root directory exists
		if !File.directory? RubyDrop.config['rubydrop_root'] then
			# If not, create it
			FileUtils.mkdir_p RubyDrop.config['rubydrop_root']
		end
		
		# Now check to see if it's a git repository or not
		if !File.directory? RubyDrop.config['rubydrop_root'] + "/.git" then
			puts "Creating git repository..."
			@repo = Repo.init(RubyDrop.config['rubydrop_root'])
		else
			puts "Opening git repository..."
			@repo = Repo.new(RubyDrop.config['rubydrop_root'])
		end
		
	end
	
	public
	
	def set_interval=(interval)
		interval = interval.to_i
		
		if interval <= 0 then
			@interval
		else
			@interval = interval
		end
	end
	
	def start()
		while @run do
			puts "\n====== Checking Folder Status ======"
			
			change_count = 0
			
			@repo.status.each do |file|
				if file.untracked then
					puts "Untracked: " + file.path
					
					change_count += 1
				elsif file.changed then
					puts "Changed: " + file.path
					
					change_count += 1
				elsif file.deleted then
					puts "Deleted: " + file.path
					
					change_count += 1
				end
			end
			
			puts "====== End Folder Status ======"
			
			if change_count > 0 then
				puts change_count.to_s + " files changed, committing..."
				if @repo.commit_all(change_count.to_s + " files updated") then
					puts "Files committed!"
				else
					puts "Error committing files?"
				end
			end
			
			change_count = 0
						
			# wait for however many seconds before checking again
			sleep @interval
		end
	end
end