begin
  require 'bundler/setup'
rescue LoadError
  retry if require 'rubygems'
end

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

Bundler.require(:default, :development)

#
# Utility
# 
API_H_PATH = File.expand_path('../api.h', __FILE__)
API_H_SRC  = File.read API_H_PATH
API_H_XML  = RbGCCXML.parse(API_H_PATH)

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
end

describe "functions" do
  API_H_XML.functions.each do |func|
    next unless func["name"] =~ /\Asp_/
    attached_name = func["name"].sub(/\Asp_/, '')
    
    describe func["name"] do
      it "should be attached" do
        Spotify.must_respond_to attached_name
      end
      
      it "should expect the correct number of arguments" do
        Spotify.attached_methods[attached_name][:args].count.
          must_equal func.arguments.count
      end
      
      # it "should expect the correct types of arguments"
      # it "should return the correct type"
    end
  end
end

describe "enums" do
  API_H_XML.enumerations.each do |enum|
    attached_enum = Spotify.enum_type enum["name"].sub(/\Asp_/, '').to_sym
    original_enum = enum.values.map { |v| [v["name"].downcase, v["init"]] } # TODO: SP_BITRATE_X => X
    
    describe enum["name"] do
      it "should exist" do
        attached_enum.wont_be_nil
      end
      
      it "should match the definition" do
        attached_enum_map = attached_enum.symbol_map
        original_enum.each do |(name, value)|
          a_name, a_value = attached_enum_map.find { |(n, v)| name.match n.to_s }
          attached_enum_map.delete(a_name)
          
          unless a_value.to_s == value.to_s
              p enum["name"]
              p [name, value]
              p [a_name, a_value]
              puts
          end
          
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
end