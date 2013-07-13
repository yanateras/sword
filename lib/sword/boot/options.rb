# coding: utf-8
module Sword
  module Boot
    module Options
      def set_build(parser)
        parser.on '-b', '--build', 'Build project into .zip' do
          @options[:build] = true
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
          @options[:directory] = name
        end
      end

      def set_error(parser)
        parser.on '-e', '--error <page>', 'Specify error page' do |page|
          @options[:error] = page
        end
      end

      def set_favicon(parser)
        parser.on '-f', '--favicon <i>', 'Specify favicon' do |icon|
          @options[:favicon] = icon
        end
      end

      def set_gem(parser)
        parser.on '--gem <name>', 'Add a gem to require' do |name|
          Loader.add_to_load(name)
          exit
        end
      end

      def set_generate(parser)
        parser.on '-g', '--generate', 'Generate boilerplate' do
          @options[:generate] = true
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
          @options[:load_file] = file
        end
      end

      def set_manual(parser)
        parser.on '-m', '--manual <x,y>', 'Specify gems to require' do |gems|
          gems.each { |g| require g }
          @options[:unload] = true
        end
      end

      def set_port(parser)
        parser.on '-p', '--port <num>', 'Change the port, 1111 by default' do |num|
          @options[:port] = num
        end
      end

      def set_settings(parser)
        parser.on '-S', '--settings <f>', 'Load settings from file' do |f|
          @options[:settings] = f
        end
      end

      def set_silent(parser)
        parser.on '-s', '--silent', 'Try to turn off any messages' do
          @options[:silent] = true
        end
      end

      def set_unload(parser)
        parser.on '-u', '--unload', 'Skip heuristically loading gems' do
          @options[:unload] = true
        end
      end

      def set_version(parser)
        parser.on '-v', '--version', 'Print Sword’s version' do
          require 'sword/version'
          puts 'Sword ' + VERSION
          exit
        end
      end
    end
  end
end
