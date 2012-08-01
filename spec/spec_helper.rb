# encoding: utf-8
require 'rbgccxml'
require 'rspec'
require 'pry'

require 'spec/support/hook_spotify'
require 'spec/support/spotify_util'

# You can pregenerate new XML files through:
# gccxml spec/api-mac.h -fxml=spec/api-mac.xml
# gccxml spec/api-linux.h -fxml=spec/api-linux.xml
API_H_PATH = File.expand_path("../api-#{Spotify.platform}.h", __FILE__)
API_H_SRC  = File.read(API_H_PATH)
API_H_XML  = RbGCCXML.parse_xml(API_H_PATH.sub('.h', '.xml'))
