require 'rbconfig'

module Sword
  # Check if we’re running Windows there:
  WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
end
