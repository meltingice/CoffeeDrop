$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'inline'

require 'ruby-kqueue/event'
require 'ruby-kqueue/vnode_event'

module RubyKQueue
  VERSION = '1.0.0'
end
