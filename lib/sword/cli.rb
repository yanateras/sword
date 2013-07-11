# coding: utf-8
require 'optparse'

module Sword
  # Sword command line interface
  # @api private
  class CLI
    def initialize(width = 18, &block)
      @parser = OptionParser.new do |o|
        o.summary_width = width
        set_options(o)
        if block_given?
          o.separator 'Plugin options:'
          yield o
        end
      end
    end

    def run(arguments = ARGV)
      @parser.parse!(arguments.dup)
    end

    def run!(arguments = ARGV)
      @parser.parse!(arguments)
    end

    protected

    def set_options(parser)
      setters = methods.delete_if { |m| not m.to_s.start_with? 'set_' }
      setters.delete(:set_options)
      setters.each do |m|
        send m, parser
      end
    end

    def set_compress(parser)
      parser.on '-c', '--compress', 'Compress assets' do 
        @options[:compress] = true
      end
    end

    def set_debug(parser)
      parser.on '-D', '--debug', 'Show server’s guts' do
        @options[:debug] = true
      end
    end

    def set_dir(parser)
      parser.on '-d', '--dir <name>', 'Specify watch directory' do |name|
        options[:directory] = name
      end
    end

    def set_error(parser)
      parser.on '-e', '--error <page>', 'Specify error page' do
        abort '--error option not implemented'
      end
    end

    def set_favicon(parser)
      parser.on '-f', '--favicon <i>', 'Specify favicon' do |icon|
        options[:favicon] = icon
      end
    end

    def set_gem(parser)
      parser.on '-g', '--gem <name>', 'Add a gem to require' do |name|
        Loader.add_to_load(name)
        exit
      end
    end

    def set_help(parser)
      parser.on '-h', '--help', 'Print this message' do
        puts parser
        exit
      end
    end

    def set_install(parser)
      parser.on '-i', '--install', 'Try to install must-have gems' do
        Loader.install_gems
        exit
      end
    end

    def set_load(parser)
      parser.on '-l', '--load <file>', 'Load gems from specified file' do |file|
        Loader.load_file = file
      end
    end

    def set_manual(parser)
      parser.on '-m', '--manual <x,y>', 'Specify gems to require' do |gems|
        gems.each { |g| require g }
        options[:unload] = true
      end
    end

    def set_port(parser)
      parser.on '-p', '--port <num>', 'Change the port, 1111 by default' do |num|
        options[:port] = num
      end
    end

    def set_settings(parser)
      parser.on '-S', '--settings <file>', 'Load settings from file' do |file|
        Loader.settings_file = file
      end
    end

    def set_silent(parser)
      parser.on '-s', '--silent', 'Try to turn off any messages' do
        options[:silent] = true
      end
    end

    def set_unload(parser)
      parser.on '-u', '--unload', 'Skip heuristically loading gems' do
        options[:unload] = true
      end
    end

    def set_version(parser)
      parser.on '-v', '--version', 'Print Sword’s version' do
        puts 'Sword ' + VERSION
        exit
      end
    end
  end
end
