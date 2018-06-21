require 'aruba/cucumber'
require 'methadone/cucumber'
require 'webrick'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s
end

After do
  ENV['RUBYLIB'] = @original_rubylib
end

AfterConfiguration do
	RubyMock.start
end

After do
  ENV['RUBYLIB'] = @original_rubylib
	RubyMock.clear
end

Aruba.configure do |config|
  config.home_directory = '.'
end

class RubyMock
  class << self; attr_accessor :resources end
  class << self; attr_accessor :requests end
  class << self; attr_accessor :rate_limiting end
  @resources = {}
  @requests = []
  @rate_limiting = false

  def self.clear
    @requests = []
    @rate_limiting = false
    @resources = {}
  end

  def self.enable_rate_limiting()
    @rate_limiting = true
  end

  def self.start
    server = WEBrick::HTTPServer.new(Port: 8000, AccessLog: [], Logger: WEBrick::Log::new("/dev/null", 7))
    server.mount_proc '/' do |req, res|
      @requests << req.body
      if @rate_limiting
        res.status = 429
        res.body = "Please try again in a few moments."
      else
        res.body = @resources[req.path]
      end
    end
    Thread.new do
      server.start
    end
  end
end
