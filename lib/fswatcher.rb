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
		Dir.chdir(RubyDrop.config['rubydrop_root']) do
			if !File.directory? ".git" then
				puts "Creating git repository..."
				@repo = Repo.init('.')
			else
				puts "Opening git repository..."
				@repo = Repo.new('.')
			end
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
		Dir.chdir(RubyDrop.config['rubydrop_root']) do
			while @run do
				puts "\n====== Checking Folder Status ======"
				
				add_count = 0
				change_count = 0
				
				@repo.status.each do |file|
					if file.untracked then
						puts "Untracked: " + file.path
						add_count += 1
						change_count += 1
					elsif file.type == 'A' then
						puts "Added: " + file.path
						
						change_count += 1
					elsif file.type == 'M' then
						puts "Changed: " + file.path
						
						change_count += 1
					elsif file.type == 'D' then
						puts "Deleted: " + file.path
						
						change_count += 1
					end
				end
				
				if add_count == 0 && change_count == 0 then
					puts "No changes"
				end
				
				if add_count > 0 then
					puts add_count.to_s + " files added, adding..."
					@repo.add('.')
				end
				
				if change_count > 0 then
					puts change_count.to_s + " files changed, committing..."
					if @repo.commit_all(change_count.to_s + " files updated") then
						puts "Files committed!"
					else
						puts "Error committing files?"
					end
				end
				
				add_count = 0
				change_count = 0
				
				puts "====== End Folder Status ======"
							
				# wait for however many seconds before checking again
				sleep @interval
			end
		end
	end
end