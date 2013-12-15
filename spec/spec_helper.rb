# encoding: utf-8
require "rbgccxml"
require "rspec"
require "pry"
require "stringio"

require "spec/support/hook_spotify"
require "spec/support/spotify_util"
require "spec/support/spy_output"

# You can pregenerate new XML files through:
# gccxml spec/api-mac.h -fxml=spec/api-mac.xml
# gccxml spec/api-linux.h -fxml=spec/api-linux.xml
API_H_PATH = File.expand_path("../support/api-#{Spotify.platform}.h", __FILE__)
API_H_SRC  = File.read(API_H_PATH)
API_H_XML  = RbGCCXML.parse_xml(API_H_PATH.sub('.h', '.xml'))

RSpec.configure do |config|
  def api
    Spotify::API
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run_excluding(engine: ->(engine) do
    ! Array(engine).include?(RUBY_ENGINE)
  end)

  config.filter_run_excluding(ruby_version: ->(requirement) do
    ruby_version = Gem::Version.new(RUBY_VERSION)
    required_version = Gem::Requirement.new(requirement)
    ! required_version.satisfied_by?(ruby_version)
  end)

  config.around(:each) do |test|
    _, warnings = spy_output { test.run }
    if warnings =~ %r"lib/spotify" and not $DEBUG
      raise "#{example.description.inspect} caused a warning, #{warnings.inspect}"
    end
  end

  # Increase idle time of the reaper during reaper specs, to avoid
  # race conditions which could cause randomly failing tests.
  config.around(:each, reaper: true) do |test|
    Spotify::Reaper.instance.terminate!
    Spotify::Reaper.instance = Spotify::Reaper.new(2)
    test.run
    Spotify::Reaper.instance.terminate!
  end
end
