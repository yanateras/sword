module Sword
  module Windows
    # Show options menu and then get options from STDIN
    # 
    # @param options [OptionParser] optparse object
    # @return [Array] options received from STDIN
    def self.get_options(options)
      [:INT, :TERM].each { |s| trap(s) { abort "\n" } }
      options.banner = 'Options (press ENTER if none):'
      print options, "\n"
      STDIN.gets.split
    end

    # Check if we’re running Windows there:
    WINDOWS = RUBY_PLATFORM =~ /mswin|windows|win32|mingw|cygwin/
  end
end
