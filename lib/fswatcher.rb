require 'rubygems'
require 'grit'
require_relative 'logmodule' 

include Grit

class FSWatcher

  include LoggerModule
  attr_accessor :run

  def initialize()
    
    @interval = RubyDrop.config['check_interval'] || 5
    @run = true
    @log = get_logger('log/git.log', 10, 1024000, RubyDrop.config['rubydrop_debug'] ? Logger::DEBUG : Logger::WARN);
  
    # Check to make sure the root directory exists
    if !File.directory? RubyDrop.config['rubydrop_root'] then
      # If not, create it
      FileUtils.mkdir_p RubyDrop.config['rubydrop_root']
    end
    
    Git.git_timeout = 300
    
    # Now check to see if it's a git repository or not
    Dir.chdir(RubyDrop.config['rubydrop_root']) do
      if !File.directory? ".git" then
        @log.info("Creating git repository...")
        @repo = Repo.init('.')
        
        @git = Git.new(RubyDrop.config['rubydrop_root'] + '/.git')
        
        @log.info('Adding remote to git repository')
        remote = "#{RubyDrop.config['remote_user']}@#{RubyDrop.config['remote_addr']}:#{RubyDrop.config['remote_path']}"
        #@repo.remote_add('origin', remote)
        @git.native('remote add', {}, 'origin', remote)
      else
        @log.info("Opening git repository...")
        @git = Git.new(RubyDrop.config['rubydrop_root'] + '/.git')
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
  
  def start
    Dir.chdir(RubyDrop.config['rubydrop_root']) do
      
      # since checking for remote status uses bandwidth each time,
      # lets only check for it every other interval
      remote_check = false
      counter = 0
      
      while @run do
        
        # only do a remote check every other interval
        if remote_check then
          @log.info("====== Checking Remote Status ======")

          remote_head = @git.native('ls-remote', {}, 'origin', 'HEAD')

          if !remote_head.empty? then
            # only split the result if there was one..for a new/empty repo this can be empty
            # which is why the check was put in to test for emptiness
            remote_head = remote_head.split("\t")[0].strip
          end

	  local_head = @git.native('rev-parse', {}, 'HEAD').strip
          
          @log.info("Current remote: #{remote_head}")
          @log.info("Current local: #{local_head}")
          
          unless remote_head == local_head then
            @log.info("Remote is ahead, fast-forwarding...")
            @git.native('reset', {:hard => true}, 'HEAD')
            @git.native('pull', {}, 'origin', 'master')
            @log.info("Fast-forward finished!")
          end
          
          @log.info("====== End Remote Status ======")
          
          remote_check = false
        else
          remote_check = true
        end
        
        @log.info("====== Checking Folder Status ======")
        
        add_count = 0
        change_count = 0
        
        @repo.status.each do |file|
          if file.untracked then
            @log.info("Untracked: " + file.path)
            add_count += 1
            change_count += 1
          elsif file.type == 'A' then
            @log.info("Added: " + file.path)
            
            change_count += 1
          elsif file.type == 'M' then
            @log.info("Changed: " + file.path)
            
            change_count += 1
          elsif file.type == 'D' then
            @log.info("Deleted: " + file.path)
            
            change_count += 1
          end
        end
        
        if add_count > 0 then
          @log.info(add_count.to_s + " files added, adding...")
          @repo.add('.')
        end
        
        if change_count > 0 then
          @log.info(change_count.to_s + " files changed, committing...")
          if @repo.commit_all(change_count.to_s + " files updated") then
            @log.info("Files committed!")
          else
            @log.error("Error committing files?")
          end
        end
        
        if add_count == 0 && change_count == 0 then
          @log.info("No changes")
        else
          @log.info('Pushing changes to remote...')
          
          # Unfortunately, at this time, Grit doesn't support remote pushing,
          # so we have to directly use Git
          @git.native('push', {}, 'origin', 'master')
          
          @log.info('Git push complete!')
          
          # clean up the git repo every 10 pushes
          if counter.modulo(10) == 0 && counter != 0 then
            @log.info("Cleaning up repository...")
            @git.native('gc', {:auto => true})
            @log.info("Cleaning finished!")
            counter = 0
          else
            counter += 1
          end

        end
        
        add_count = 0
        change_count = 0
        
        @log.info("====== End Folder Status ======")
              
        # wait for however many seconds before checking again
        sleep @interval
      end
    end
  end
end
