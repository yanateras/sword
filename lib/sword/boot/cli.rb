require 'sword/boot/options'
require 'optparse'

module Sword
  module Boot
    # Sword command line interface
    # @api private
    class CLI
      def initialize(width = 18, &block)
        @parser = OptionParser.new do |parser|
          parser.summary_width = width
          set_options(parser)
          if block_given?
            parser.separator 'Plugin options:'
            yield parser
          end
        end
      end

      def run(arguments = ARGV)
        require 'sword/boot/manager'
        Manager.new parse!(arguments)
      end

      def parse(arguments = ARGV)
        parse!(arguments.dup)
      end

      def parse!(arguments = ARGV)
        @options = {}
        arguments = get_options(@parser) unless arguments
        @parser.parse!(arguments)
        @options
      end

      protected

      # Show options menu and then get options from STDIN
      # 
      # @param parser [OptionParser] optparse object
      # @return [Array] options received from STDIN
      def get_options(parser)
        [:INT, :TERM].each { |s| trap(s) { abort "\n" } }
        parser.banner = 'Options (press ENTER if none):'
        print parser, "\n"
        STDIN.gets.split
      end

      def set_options(parser)
        setters = methods.delete_if { |m| not m.to_s.start_with? 'set_' }
        setters.delete(:set_options)
        setters.each do |m|
          send m, parser
        end
      end

      include Options
    end
  end
end
