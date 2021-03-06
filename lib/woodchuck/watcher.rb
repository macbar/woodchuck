require 'filewatch/tail'
require 'addressable/uri'
require 'yajl'
require 'socket'
require 'time'
require 'thread'
require 'forwardable'

class Woodchuck::Watcher
  extend Forwardable
  
  attr_accessor :tailer, :paths, :logger, :events, :agent
  def_delegator :@agent, :output, :output
  
  def initialize(agent, *paths)
    @agent = agent
    @logger = Woodchuck::Logger.new(::STDOUT)
    @tailer = FileWatch::Tail.new
    @paths = paths.flatten
  end

  def start
    paths.each do |path|
      tailer.tail(path)
    end
    tailer.subscribe do |path, line|
      event = Woodchuck::Event.new(path, line)
      output.handle(event)
    end
  end
  
  def inspect
    to_s
  end
end
