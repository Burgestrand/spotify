# coding: utf-8
require 'ostruct'
require 'set'
require 'rbgccxml'
require 'minitest/mock'
require 'minitest/autorun'

#
# Hooking FFI for extra introspection
#
require 'ffi'

module Spotify
  extend FFI::Library
  extend self

  def ffi_lib(*)
    super
  rescue LoadError => e
    puts "[WARN] libspotify is unavailable. Installing it strongly recommended, even for running tests."
  end

  def build_id
    Spotify::API_VERSION
  end

  def attach_function(name, func, arguments, returns = nil, options = nil)
    args = [name, func, arguments, returns, options].compact
    args.unshift name.to_s if func.is_a?(Array)

    hargs = [:name, :func, :args, :returns].zip args
    @attached_methods ||= {}
    @attached_methods[name.to_s] = hash = Hash[hargs]

    begin
      super
    rescue FFI::NotFoundError => e
      puts "[WARN] #{name}(#{hash}) not found in libspotify"
    rescue LoadError
      # happens if libspotify did not load
      #
      # to make sure the method is defined:
      define_singleton_method(name, proc { |*args| }) unless method_defined?(name)
    end
  end

  def resolve_type(type)
    type = find_type(type)
    type = type.type if type.respond_to?(:type)
    type
  end

  def structs
    constants.select { |x| const_get(x).is_a?(Class) && const_get(x) < FFI::Struct }
  end

  attr_reader :attached_methods

  RUBY_PLATFORM = ENV.fetch('RUBY_PLATFORM') do
    puts "[WARN] Tests running with default ruby platform, #{::RUBY_PLATFORM}, please be"
    puts "[WARN] specific in which platform to target by setting ENV[RUBY_PLATFORM]"
    puts "(warnings coming from #{__FILE__}:#{__LINE__})"
    puts
    ::RUBY_PLATFORM
  end
end

require 'spotify'

module C
  extend FFI::Library
  ffi_lib [FFI::CURRENT_PROCESS, 'c']

  attach_function :strncpy, [ :pointer, Spotify::UTF8String, :size_t ], Spotify::UTF8String
end

# Used for checking Spotify::Pointer things.
module Spotify
  def bogus_add_ref(pointer)
  end

  # This may be called after our GC test. Randomly.
  def bogus_release(pointer)
  end

  class Bogus < ManagedPointer
  end
end

#
# Utility
#

# You can pregenerate new XML files through:
# gccxml spec/api-mac.h -fxml=spec/api-mac.xml
# gccxml spec/api-linux.h -fxml=spec/api-linux.xml
API_H_PATH = File.expand_path("../api-#{Spotify.platform}.h", __FILE__)
API_H_SRC  = File.read(API_H_PATH)
API_H_XML  = RbGCCXML.parse_xml(API_H_PATH.sub('.h', '.xml'))

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
      Spotify::API_VERSION.to_i.must_equal spotify_version.to_i
    end
  end

  describe ".enum_value!" do
    it "raises an error if given an invalid enum value" do
      proc { Spotify.enum_value!(:moo, "error value") }.must_raise(ArgumentError)
    end

    it "gives back the enum value for that enum" do
      Spotify.enum_value!(:ok, "error value").must_equal 0
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

  describe "error wrapped functions" do
    wrapped_methods = Spotify.attached_methods.find_all { |meth, info| info[:returns] == :error }
    wrapped_methods.each do |meth, info|
      it "raises an error if #{meth}! returns non-ok" do
        Spotify.stub(meth, :bad_application_key) do
          proc { Spotify.send("#{meth}!") }.must_raise(Spotify::Error, /BAD_APPLICATION_KEY/)
        end
      end
    end
  end

  describe ".attach_function" do
    it "is a retaining class if the method is not creating" do
      Spotify.attach_function :whatever, [], Spotify::User
      Spotify.attached_methods["whatever"][:returns].must_equal Spotify::User.retaining_class
    end

    it "is a non-retaining class if the method is creating" do
      Spotify.attach_function :whatever_create, [], Spotify::User
      Spotify.attached_methods["whatever_create"][:returns].must_equal Spotify::User
      Spotify.attached_methods["whatever_create"][:returns].wont_equal Spotify::User.retaining_class
    end
  end

  describe Spotify::ManagedPointer do
    it "adds a ref if it is a retaining class" do
      ref_added = false

      Spotify.stub(:user_add_ref, proc { ref_added = true }) do
        ptr = Spotify::User.retaining_class.new(FFI::Pointer.new(1))
        ptr.autorelease = false
      end

      ref_added.must_equal true
    end

    it "does not add or release when the pointer is null" do
      ref_added = false
      ref_removed = false

      Spotify.stub(:user_add_ref, proc { ref_added = true }) do
        Spotify.stub(:user_release, proc { ref_removed = true }) do
          ptr = Spotify::User.retaining_class.new(FFI::Pointer::NULL)
          ptr.free
        end
      end

      ref_added.must_equal false
      ref_removed.must_equal false
    end

    describe "garbage collection" do
      let(:my_pointer) { FFI::Pointer.new(1) }

      it "should work" do
        gc_count = 0

        Spotify.stub(:bogus_release, proc { gc_count += 1 }) do
          5.times { Spotify::Bogus.new(my_pointer) }
          5.times { GC.start; sleep 0.01 }
        end

        # GC tests are a bit funky, but as long as we garbage_release at least once, then
        # we can assume our GC works properly, but up the stakes just for the sake of it
        gc_count.must_be :>, 3
      end
    end
  end

  describe "all managed pointers" do
    Spotify.constants.each do |const|
      klass = Spotify.const_get(const)
      next unless klass.is_a?(Class)
      next unless klass < Spotify::ManagedPointer

      it "#{klass.name} has a valid retain method" do
        called   = false

        asserter = lambda do |name, *args|
          Spotify.must_respond_to(name)
          name.must_match /add_ref/
          called = true
        end

        Spotify.stub(:public_send, asserter) do
          klass.retain(FFI::Pointer.new(1))
        end

        called.must_equal true
      end unless klass == Spotify::Session # has no valid retain

      it "#{klass.name} has a valid release method" do
        called   = false

        asserter = lambda do |name, *args|
          Spotify.must_respond_to(name)
          name.must_match /release/
          called = true
        end

        Spotify.stub(:public_send, asserter) do
          klass.release(FFI::Pointer.new(1))
        end

        called.must_equal true
      end
    end
  end

  describe Spotify::UTF8String do
    let(:char) do
      char = "\xC4"
      char.force_encoding('ISO-8859-1') if char.respond_to?(:force_encoding)
      char
    end

    it "should convert any strings to UTF-8 before reading and writing" do
      dest   = FFI::MemoryPointer.new(:char, 3) # two bytes for the ä, one for the NULL
      result = C.strncpy(dest, char, 3)

      result.encoding.must_equal Encoding::UTF_8
      result.must_equal "Ä"
      result.bytesize.must_equal 2
    end if "".respond_to?(:force_encoding)

    it "should do nothing if strings does not respond to #encode or #force_encoding" do
      dest   = FFI::MemoryPointer.new(:char, 3) # two bytes for the ä, one for the NULL
      result = C.strncpy(dest, char, 3)

      result.must_equal "\xC4"
      result.bytesize.must_equal 1
    end unless "".respond_to?(:force_encoding)
  end

  describe Spotify::ImageID do
    let(:context) { nil }
    let(:subject) { Spotify.find_type(Spotify::ImageID) }
    let(:null_pointer) { FFI::Pointer::NULL }

    let(:image_id_pointer) do
      pointer = FFI::MemoryPointer.new(:char, 20)
      pointer.write_string(image_id)
      pointer
    end

    let(:image_id) do
      # deliberate NULL in middle of string
      image_id = ":\xD94#\xAD\xD9\x97f\xE0\x00V6\x05\xC6\xE7n\xD2\xB0\xE4P"
      image_id.force_encoding("BINARY") if image_id.respond_to?(:force_encoding)
      image_id
    end

    describe "from_native" do
      it "should be nil given a null pointer" do
        subject.from_native(null_pointer, context).must_be_nil
      end

      it "should be an image id given a non-null pointer" do
        subject.from_native(image_id_pointer, context).must_equal image_id
      end
    end

    describe "to_native" do
      it "should be a null pointer given nil" do
        subject.to_native(nil, context).must_be_nil
      end

      it "should be a 20-byte C string given an actual string" do
        pointer = subject.to_native(image_id, context)
        pointer.read_string(20).must_equal image_id_pointer.read_string(20)
      end

      it "should raise an error given more or less than a 20 byte string" do
        proc { subject.to_native(image_id + image_id, context) }.must_raise ArgumentError
        proc { subject.to_native(image_id[0..10], context) }.must_raise ArgumentError
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
          Spotify::UTF8String
        when /\A(::)?(char|int|size_t|bool|sp_scrobbling_state|sp_session\*|byte)\*/
          return_type ? :pointer : :buffer_out
        when /::(.+_cb)\*/
          $1.to_sym
        when /::sp_(\w+)\*/
          const_name = $1.delete('_')
          real_const = Spotify.constants.find { |const| const =~ /#{const_name}/i }
          Spotify.const_get(real_const)
        else
          :pointer
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

        if actual.is_a?(Class) and actual <= Spotify::ManagedPointer
          actual.must_be :>=, current
        else
          Spotify.resolve_type(current).must_equal Spotify.resolve_type(actual)
        end
      end

      it "should expect the correct types of arguments" do
        current = Spotify.attached_methods[attached_name][:args]
        actual  = func.arguments.map { |arg| type_of(arg.cpp_type) }

        current = current.map { |x| Spotify.resolve_type(x) }
        actual  = actual.map  { |x| Spotify.resolve_type(x) }

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
          a_name, a_value = attached_enum_map.max_by { |(n, v)| (n.to_s.length if name.match(n.to_s)).to_i }
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

    attached_struct = Spotify.structs.find do |const|
      struct["name"].delete('_').match(/#{const}/i)
    end

    attached_members = Spotify.const_get(attached_struct).members.map(&:to_s)

    describe struct["name"] do
      it "should contain the same attributes" do
        struct.variables.map(&:name).each_with_index do |member, index|
          attached_members[index].must_equal member
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
