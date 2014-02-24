require "bundler/setup"
require "spotify"
require "logger"
require "pry"
require "io/console"

# Kill main thread if any other thread dies.
Thread.abort_on_exception = true

# We use a logger to print some information on when things are happening.
$stderr.sync = true
$logger = Logger.new($stderr)
$logger.level = Logger::INFO
$logger.formatter = proc do |severity, datetime, progname, msg|
  progname = if progname
    " (#{progname}) "
  else
    " "
  end
  "\n[#{severity} @ #{datetime.strftime("%H:%M:%S")}]#{progname}#{msg}"
end

#
# Some utility.
#

module Support
  module_function

  DEFAULT_CONFIG = Spotify::SessionConfig.new({
    api_version: Spotify::API_VERSION.to_i,
    application_key: File.binread("./spotify_appkey.key"),
    cache_location: ".spotify/",
    settings_location: ".spotify/",
    user_agent: "spotify for ruby",
    callbacks: Spotify::SessionCallbacks.new
  })

  def logger
    $logger
  end

  # libspotify supports callbacks, but they are not useful for waiting on
  # operations (how they fire can be strange at times, and sometimes they
  # might not fire at all). As a result, polling is the way to go.
  def poll(session, idle_time = 0.05)
    until yield
      print "."
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

  # Ask the user for input with a prompt explaining what kind of input.
  def prompt(message, default = nil)
    if default
      print "\n#{message} [#{default}]: "
      input = gets.chomp

      if input.empty?
        default
      else
        input
      end
    else
      print "\n#{message}: "
      gets.chomp
    end
  end

  def initialize_spotify!(config = DEFAULT_CONFIG)
    session = FFI::MemoryPointer.new(Spotify::Session) do |ptr|
      Spotify.try(:session_create, config, ptr)
      break Spotify::Session.new(ptr.read_pointer)
    end

    remembered_user_length = Spotify.session_remembered_user(session, nil, 0)

    if remembered_user_length > 0
      username = FFI::MemoryPointer.new(:int, remembered_user_length + 1) do |username_ptr|
        Spotify.session_remembered_user(session, username_ptr, username_ptr.size)
        break username_ptr.read_string.force_encoding("UTF-8")
      end

      logger.info "Using remembered login for: #{username}."
      Spotify.try(:session_relogin, session)
    else
      username = prompt("Spotify username, or Facebook e-mail")
      password = $stdin.noecho { prompt("Spotify password, or Facebook password") }

      logger.info "Attempting login with #{username}."
      Spotify.try(:session_login, session, username, password, true, nil)
    end

    logger.info "Log in requested. Waiting forever until logged in."
    Support.poll(session) { Spotify.session_connectionstate(session) == :logged_in }

    at_exit do
      logger.info "Logging out."
      Spotify.session_logout(session)
      Support.poll(session) { Spotify.session_connectionstate(session) != :logged_in }
    end

    session
  end
end
