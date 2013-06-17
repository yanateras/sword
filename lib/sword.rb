module Sword
  require 'rubygems'
  require 'sinatra/base'
  require 'yaml'

  REQUIRED = Dir.home + '/.sword'
  LIBRARY  = File.dirname __FILE__
  PARSE    = YAML.load_file "#{LIBRARY}/parse.yml"
  VERSION  = '0.8.3'

  class Application < Sinatra::Base
    # This piece of code is from Sinatra,
    # tweaked a bit to silent Thin server
    # and add Sword version and &c.
    NotFound = Class.new StandardError
    class << self
      # Input/output

      def puts(*args)
        STDERR.puts(*args) unless @silent
      end

      def print(*args)
        STDERR.print(*args) unless @silent
      end

      def debug(message, symbol = false)
        if @debug
          return print symbol * 2 + ' ' + message if symbol
          print message
        end
      end


      # Sinatra-related

      def run!(options = {})
        options = {:debug => false, :directory => Dir.pwd, :port => 1111, :silent => false}.merge(options)
        @debug, @silent = options[:debug], options[:silent]
        load unless options[:unload]
        init

        server_settings = settings.respond_to?(:server_settings) ? settings.server_settings : {}
        detect_rack_handler.run self, server_settings.
          merge(:Port => options[:port], :Host => bind).
          merge( defined?(WEBrick) && !(@debug) ? {:AccessLog => [], :Logger => WEBrick::Log::new("/dev/null", 7)} : {} ) do |server|
            [:INT, :TERM].each { |s| trap(s) { quit!(server) } }
            print ">> Sword #{VERSION} at your service!\n" \
            "   http://localhost:#{options[:port]} to see your project.\n" \
            "   CTRL+C to stop.\n"
            debug options.map { |k,v| "## #{k.capitalize}: #{v}\n" }.inject { |sum, n| sum + n }
            unless @debug
              server.silent = true if server.respond_to? :silent
              disable :show_exceptions
            end
            set :views, options[:directory] # Structure-agnostic
            set :public_folder, settings.views
            server.threaded = settings.threaded if server.respond_to? :threaded
            set :running, true
            yield server if block_given?
        end
      rescue Errno::EADDRINUSE, RuntimeError
        print "!! Port is in use. Is Sword already running?\n"
      end

      def quit!(server)
        print "\n"
        server.respond_to?(:stop!) ? server.stop! : server.stop
      end


      # Sword-specific

      def parse(list, pattern, options = {}, &block)
        self.get pattern do |file|
          begin
            output = pattern[/(?<=\.).+$/]
            return send_file "#{file}.#{output}" if output and File.exists? "#{file}.#{output}"
            PARSE[list].map { |e| String === e ? {e => [e]} : e }.each do |language|
              language.each do |engine, extensions| extensions.each do |extension|
                # Iterate through extensions and find the engine you need.
                return send engine, file.to_sym, options if File.exists? "#{file}.#{extension}"
              end end
            end
            raise NotFound
          rescue NotFound
            block_given? ? yield(file) : raise
          end
        end
      end

      def load
        debug "Loading gems:\n", ' '
        PARSE['gems'].concat(File.exists?(REQUIRED) ? File.read(REQUIRED).split("\n") : []).each do |lib|
          # Hash case (a lot of variants)
          Hash === lib ?
          lib.values.first.each do |variant|
            begin
              debug variant + '.' * (15 - variant.length), '  '
              require variant
              debug "OK\n"
              break
            rescue LoadError
              debug "Fail\n"
              next
            end
          end

          :
          begin
            debug lib + '.' * (15 - lib.length), '  '
            require lib
            debug "OK\n"
          rescue LoadError
            debug "Fail\n"
          end
        end

        load_compass if defined? Compass
      end

      def load_compass
        Compass.add_project_configuration "#{LIBRARY}/compass.rb"
        @compass = Compass.sass_engine_options
      end

      def init
        helpers do
          def font(options) end
          def jquery(version = '1.8.3')
            "<script src='//ajax.googleapis.com/ajax/libs/jquery/#{version}/jquery.min.js'/>"
          end
        end

        error do
          @error = env['sinatra.error']
          erb :error, :views => LIBRARY
        end

        get '/favicon.ico' do
          send_file "#{LIBRARY}/favicon.ico"
        end

        get '/' do
          # Call /index, the same shit
          call env.merge 'PATH_INFO' => '/index'
        end

        parse 'styles', '/*.css', (@compass || {})
        parse 'scripts', '/*.js'

        get %r{(.+?)\.(#{PARSE['html'] * '|'})} do |route, _|
          call env.merge 'PATH_INFO' => route
        end

        set :slim, :pretty => true
        parse 'pages', '/*/?' do |page|
          PARSE['html'].each do |extension|
            # If you know another ultra-dumbass html extension, let me know.
            return send_file "#{page}.#{extension}" if File.exist? "#{page}.#{extension}"
          end
          raise NotFound if page =~ /\/index$/ or not defined? env
          call env.merge({'PATH_INFO' => "/#{page}/index"})
        end
      end
    end
  end
end
