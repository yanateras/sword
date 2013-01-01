module Sword
  require 'yaml'
  LIBRARY = File.dirname __FILE__
  REQUIRED = Dir.home + '/.sword'
  PARSING = YAML.load_file "#{LIBRARY}/parsing.yml"
  VERSION = '0.6.0'
end
