require 'rubygems' unless defined?(gem)
gem 'minitest'
require 'minitest/autorun'
require 'minitest/spec'

begin require 'minitest-rg'
rescue LoadError; end

require 'rbgccxml'

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
    original_enum = Hash[enum.values.map do |v|
      [v["name"].downcase, v["init"]]
    end]
    
    describe enum["name"] do
      it "should exist" do
        attached_enum.wont_be_nil
      end
      
      it "should match the definition" do
        attached_enum.symbol_map.sort_by { |k, v| -k.to_s.size }.each do |(key, value)|
          k, v = original_enum.find { |x, _| x.match key.to_s }
          v.must_equal value.to_s
          original_enum.delete(k)
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
    
    describe struct["name"] do
      it "should contain the same attributes" do
        original_members = struct.variables.map(&:name)
        
        Spotify.const_get(attached_struct).members.each do |member|
          original_members.must_include member.to_s
        end
      end
    end
  end
end