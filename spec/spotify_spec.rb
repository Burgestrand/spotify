require 'rubygems' # needed for 1.8, does not matter in 1.9
require 'bundler/setup'

require 'rbgccxml'
require 'minitest/autorun'

#
# Hooking FFI for extra introspection
#
require 'ffi'

module Spotify
  extend FFI::Library
  extend self

  def attach_function(name, func, arguments, returns = nil, options = nil)
    args = [name, func, arguments, returns, options].compact
    args.unshift name.to_s if func.is_a?(Array)

    hargs = [:name, :func, :args, :returns].zip args
    @attached_methods ||= {}
    @attached_methods[name.to_s] = hash = Hash[hargs]

    super
  end

  attr_reader :attached_methods
end

require 'spotify'

#
# Utility
#

API_H_PATH = File.expand_path('../api.h', __FILE__)
API_H_SRC  = File.read(API_H_PATH)

# rbgccxml has this ugly bug, so work around it
# https://github.com/jameskilton/rbgccxml/issues/10
my_hash = { pregenerated: API_H_PATH + '.xml' }
class << my_hash
  alias :delete :to_hash
end

API_H_XML  = RbGCCXML.parse([], my_hash)

#
# General
#
describe Spotify do
  describe "VERSION" do
    it "should be defined" do
      defined?(Spotify::VERSION).must_equal "constant"
    end

    it "should be the same version as in api.h" do
      spotify_version = API_H_SRC.match(/#define\s+SPOTIFY_API_VERSION\s+(\d+)/)[1]
      Spotify::API_VERSION.must_equal spotify_version.to_i
    end
  end

  describe Spotify::SessionConfig do
    it "allows setting boolean values with bools" do
      subject = Spotify::SessionConfig.new

      subject[:compress_playlists].must_equal false
      subject[:dont_save_metadata_for_playlists].must_equal false
      subject[:initially_unload_playlists].must_equal false

      subject[:compress_playlists] = true
      subject[:dont_save_metadata_for_playlists] = true
      subject[:initially_unload_playlists] = true

      subject[:compress_playlists].must_equal true
      subject[:dont_save_metadata_for_playlists].must_equal true
      subject[:initially_unload_playlists].must_equal true
    end

    it "should be possible to set the callbacks" do
      subject = Spotify::SessionConfig.new
      subject[:callbacks] = Spotify::SessionCallbacks.new
    end
  end

  describe Spotify::OfflineSyncStatus do
    it "allows setting boolean values with bools" do
      subject = Spotify::OfflineSyncStatus.new

      subject[:syncing].must_equal false
      subject[:syncing] = true
      subject[:syncing].must_equal true
    end
  end

  describe "audio sample types" do
    # this is so we can just read audio frames easily based on the sample type
    Spotify.enum_type(:sampletype).symbols.each do |type|
      describe type do
        it "should have a corresponding FFI::Pointer#read_array_of_#{type}" do
          FFI::Pointer.new(1).must_respond_to "read_array_of_#{type}"
        end
      end
    end
  end
end

describe "functions" do
  API_H_XML.functions.each do |func|
    next unless func["name"] =~ /\Asp_/
    attached_name = func["name"].sub(/\Asp_/, '')

    def type_of(type, return_type = false)
      return case type.to_cpp
        when "const char*"
          :string
        when /\A(::)?(char|int|size_t|sp_session\*)\*/
          return_type ? :pointer : :buffer_out
        when /::(.+_cb)\*/
          $1.to_sym
        else :pointer
      end if type.is_a?(RbGCCXML::PointerType)

      case type["name"]
      when "unsigned int"
        :uint
      else
        type["name"].sub(/\Asp_/, '').to_sym
      end
    end

    describe func["name"] do
      it "should be attached" do
        Spotify.must_respond_to attached_name
      end

      it "should expect the correct number of arguments" do
        Spotify.attached_methods[attached_name][:args].count.
          must_equal func.arguments.count
      end

      it "should return the correct type" do
        current = Spotify.attached_methods[attached_name][:returns]
        actual  = type_of(func.return_type, true)

        Spotify.find_type(current).must_equal Spotify.find_type(actual)
      end

      it "should expect the correct types of arguments" do
        current = Spotify.attached_methods[attached_name][:args]
        actual  = func.arguments.map { |arg| type_of(arg.cpp_type) }

        current = current.map { |x| Spotify.find_type(x) }
        actual  = actual.map  { |x| Spotify.find_type(x) }

        current.must_equal actual
      end
    end
  end
end

describe "enums" do
  API_H_XML.enumerations.each do |enum|
    attached_enum = Spotify.enum_type enum["name"].sub(/\Asp_/, '').to_sym
    original_enum = enum.values.map { |v| [v["name"].downcase, v["init"]] }

    describe enum["name"] do
      it "should exist" do
        attached_enum.wont_be_nil
      end

      it "should match the definition" do
        attached_enum_map = attached_enum.symbol_map
        original_enum.each do |(name, value)|
          a_name, a_value = attached_enum_map.find { |(n, v)| name.match n.to_s }
          attached_enum_map.delete(a_name)
          a_value.to_s.must_equal value
        end
      end
    end
  end
end

describe "structs" do
  API_H_XML.structs.each do |struct|
    next if struct["incomplete"]

    attached_struct = Spotify.constants.find do |const|
      struct["name"].gsub('_', '').match(/#{const}/i)
    end

    attached_members = Spotify.const_get(attached_struct).members.map(&:to_s)

    describe struct["name"] do
      it "should contain the same attributes" do
        struct.variables.map(&:name).each do |member|
          attached_members.must_include member
        end
      end
    end
  end

  describe Spotify::Subscribers do
    it "should create the subscribers array using count" do
      # Memory looks like this:
      #
      # 00 00 00 00 <- count of subscribers
      # 00 00 00 00 <- pointer to subscriber 1
      # …… …… …… ……
      # 00 00 00 00 <- pointer to subscriber n
      real_struct = FFI::MemoryPointer.new(:char, 24)
      real_struct.put_uint(0, 2)
      subscribers = %w[a bb].map { |x| FFI::MemoryPointer.from_string(x) }
      real_struct.put_array_of_pointer(8, subscribers)

      struct = Spotify::Subscribers.new(real_struct)
      struct[:count].must_equal 2
      struct[:subscribers].size.must_equal 2
      struct[:subscribers][0].read_string.must_equal "a"
      struct[:subscribers][1].read_string.must_equal "bb"
      proc { struct[:subscribers][2] }.must_raise IndexError
    end


    it "should not fail given an empty subscribers struct" do
      subscribers = FFI::MemoryPointer.new(:uint)
      subscribers.write_uint(0)

      subject = Spotify::Subscribers.new(subscribers)
      subject[:count].must_equal 0
      proc { subject[:subscribers] }.must_raise ArgumentError
    end
  end
end
