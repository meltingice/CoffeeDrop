require "fileutils"
require "yaml"
require_relative "fswatcher"
require_relative "tcp_listen"

class RubyDrop
  
  def initialize()
    # Load the config
    @@config = YAML.load_file("config.yml")
    
    # Prepare the document root
    @@config['rubydrop_root'] = @@config['rubydrop_root'] || "~/RubyDrop"
    @@config['rubydrop_root'] = File.expand_path(@@config['rubydrop_root'])
    
    if @@config['git_debug'] then
      Grit.debug = true
    end
    
    # Create the filesystem watcher
    @watcher = FSWatcher.new()
    
    # and the TCP server
    TcpListen.new().start()
  end
  
  public
  
  def self.config
    return @@config
  end
  
  def run
    @watcher.start()
  end
end