require "bundler/setup"
require "spotify"
require "logger"
require "pry"

# Kill main thread if any other thread dies.
Thread.abort_on_exception = true

# We use a logger to print some information on when things are happening.
$logger = Logger.new($stderr)
$logger.level = Logger::INFO

#
# Some utility.
#

# libspotify supports callbacks, but they are not useful for waiting on
# operations (how they fire can be strange at times, and sometimes they
# might not fire at all). As a result, polling is the way to go.
def poll(session)
  until yield
    FFI::MemoryPointer.new(:int) do |ptr|
      Spotify.session_process_events(session, ptr)
    end
    sleep(0.1)
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
def prompt(message)
  print "#{message}: "
  gets.chomp
end

# Load the configuration.
$appkey = IO.read("./spotify_appkey.key", encoding: "BINARY")
$username = env("SPOTIFY_USERNAME")
$password = env("SPOTIFY_PASSWORD")
