# encoding: utf-8
require "rbgccxml"
require "rspec"
require "stringio"
require "pry"

require "spec/support/hook_spotify"
require "spec/support/spotify_util"
require "spec/support/spy_output"

# You can pregenerate new XML files through:
# gccxml spec/api-mac.h -fxml=spec/api-mac.xml
# gccxml spec/api-linux.h -fxml=spec/api-linux.xml
API_H_PATH = File.expand_path("../support/api-#{Spotify::Util.platform}.h", __FILE__)
API_H_SRC  = File.read(API_H_PATH)
API_H_XML  = RbGCCXML.parse_xml(API_H_PATH.sub('.h', '.xml'))

class << Spotify
  attr_accessor :performer
end

RSpec.configure do |config|
  def api
    Spotify::API
  end

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

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
      raise "#{test.description.inspect} caused a warning, #{warnings.inspect}"
    end
  end

  config.around(:each) do |example|
    Spotify.performer = Performer.new
    example.run
    task = Spotify.performer.shutdown
    task.value # wait for shutdown
  end
end
