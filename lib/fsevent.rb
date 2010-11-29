# if we're running Mac OSX or BSD, then require the kqueue lib
require_relative 'kqueue/ruby-kqueue' if RUBY_PLATFORM =~ /(darwin|bsd)/

# otherwise, if we're running Linux, require inotify (not implemented yet) 

class FSEvent
  
  include RubyKQueue
  
  attr_reader :dir
  
  def FSEvent.platform
    if RUBY_PLATFORM =~ /(darwin|bsd)/ then
      :mac
    else
      :linux
    end
  end
  
  def initialize(dir)
    @dir = dir
    @thread = nil
  end
  
  public
  
  def watch
    case FSEvent.platform
      when :mac then
        @thread = Thread.new { Event.handle }
        @thread.join
    end
  end
  
  def modified(&block)
    
    case FSEvent.platform
      when :mac then
        Event.register(@dir, VNodeEvent, VNodeEvent::WRITE) { yield }
        Event.register(@dir, VNodeEvent, VNodeEvent::RENAME) { yield }
    end
    
  end
  
end