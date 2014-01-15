require "bundler/setup"
require "spotify"
require "logger"
require "pry"

# Kill main thread if any other thread dies.
Thread.abort_on_exception = true

# We use a logger to print some information on when things are happening.
$stderr.sync = true
$logger = Logger.new($stderr)
$logger.level = Logger::INFO

#
# Some utility.
#

module Support
  module_function

  def logger
    $logger
  end

  # libspotify supports callbacks, but they are not useful for waiting on
  # operations (how they fire can be strange at times, and sometimes they
  # might not fire at all). As a result, polling is the way to go.
  def poll(session, idle_time = 0.01)
    until yield
      process_events(session)
      sleep(idle_time)
    end
  end

  # Process libspotify events once.
  def process_events(session)
    FFI::MemoryPointer.new(:int) do |ptr|
      Spotify.session_process_events(session, ptr)
    end
  end

  # For making sure fetching configuration options fail with a useful error
  # message when running the examples.
  def env(name)
    ENV.fetch(name) do
      raise "Missing ENV['#{name}']. Please: export #{name}='your value'"
    end
  end

  # Ask the user for input with a prompt explaining what kind of input.
  def prompt(message, default = nil)
    if default
      print "#{message} [#{default}]: "
      input = gets.chomp

      if input.empty?
        default
      else
        input
      end
    else
      print "#{message}: "
      gets.chomp
    end
  end

  def create_session(config)
    FFI::MemoryPointer.new(Spotify::Session) do |ptr|
      Spotify.try(:session_create, config, ptr)
      return Spotify::Session.new(ptr.read_pointer)
    end
  end
end

# Load the configuration.
$appkey = IO.read("./spotify_appkey.key", encoding: "BINARY")
$username = Support.env("SPOTIFY_USERNAME")
if ENV.has_key?("SPOTIFY_BLOB")
  $blob = ENV["SPOTIFY_BLOB"]
else
  $password = Support.env("SPOTIFY_PASSWORD")
end
