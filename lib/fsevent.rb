# if we're running Mac OSX or BSD, then require the kqueue lib
require_relative 'kqueue/ruby-kqueue' if RUBY_PLATFORM =~ /(darwin|bsd)/

# otherwise, if we're running Linux, require inotify (not implemented yet) 

class FSEvent
  
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
        @thread = Thread.new { RubyKQueue::Event.handle }
        @thread.join
    end
  end
  
  def modified(&block)
    
    case FSEvent.platform
      when :mac then
        RubyKQueue::Event.register(@dir, RubyKQueue::VNodeEvent, RubyKQueue::VNodeEvent::WRITE) { yield }
        RubyKQueue::Event.register(@dir, RubyKQueue::VNodeEvent, RubyKQueue::VNodeEvent::RENAME) { yield }
    end
    
  end
  
end