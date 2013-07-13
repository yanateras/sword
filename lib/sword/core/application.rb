require 'rubygems'
require 'sinatra/base'
require 'sword/core/helpers'
require 'sword/core/routes'

module Sword
  module Core
    class Application < Sinatra::Base
      NotFoundError = Class.new StandardError
      extend Output if defined? Output

      class << self

        def run!(options = {})
          @debug, @silent = options[:debug], options[:silent]
          server_settings = settings.respond_to?(:server_settings) ? settings.server_settings : {}
          initialize_engines("#{LIBRARY}/engines/*.yml")

          detect_rack_handler.run self, server_settings.merge({:Port => options[:port], :Host => bind}).merge(silent_webrick) do |server|
            [:INT, :TERM].each { |s| trap(s) { quit!(server) } }
            print ">> Sword #{VERSION} at your service!\n" \
            "   http://localhost:#{options[:port]} to see your project.\n" \
            "   CTRL+C to stop.\n"
            
            options.map { |k,v| debug "#{k.capitalize}: #{v}", '#' }
            specify_directory options[:directory]

            unless @debug
              server.silent = true if server.respond_to? :silent=
              disable :show_exceptions
            end

            server.threaded = settings.threaded if server.respond_to? :threaded
            set :running, true
            yield server if block_given?
          end
        rescue Errno::EADDRINUSE, RuntimeError
          print "!! Port is in use. Is Sword already running?\n"
        end

        private

        # Generate instance variables containing parsed versions of YAML engine lists.
        # Variable names are identical to file names.
        # @param engines [Array, String] absolute path(s) to engine lists
        # @return [Sword::Application] self
        # @note
        #   Format is as follows:
        #   string is both engine method and the only extension,
        #   hash is the key is an engine method and the value is an array of extensions
        def initialize_engines(engines)
          Array(engines).each do |file|
            self.instance_variable_set '@' + file.basename(file, '.yml'), Loader.parse_engine(file)
          end
          self
        end

        # Handles a request and tries to find a template engine capable to parse the template
        # 
        # @param list [String] instance variable containing engine list from `/engines` folder
        # @param route [String] ordinary route pattern (should be like `/*.css`)
        # @param options [Hash] hash of options to give to the found template engine
        # @param &block [Block] block to run if nothing is found
        # @raise [NotFoundError] if no template engine was found and block was not specified
        # @yield '*' from the route pattern
        def parse(list, route, options = {}, &block)
          self.get route do |name|
            list.each do |language|
              language.each do |engine, extensions|
                extensions.each do |extension|
                  return send engine, name.to_sym, options if File.exists? "#{name}.#{extension}"
                end
              end
            end
            block_given? ? yield(name) : raise(NotFoundError)
          end
        end

        # Specifies the application working directory
        # @param [String] directory absolute path
        def specify_directory(directory)
          set :views, directory # Structure-agnostic        
          set :public_folder, settings.views
        end

        # Stops the server (stolen from original Sinatra)
        def quit!(server)
          print "\n"
          server.respond_to?(:stop!) ? server.stop! : server.stop
        end

        # Silents WEBrick server (platform-specific)
        # @return [Hash] hash with settings required to silent him
        def silent_webrick
          return {} if @debug or not defined? WEBrick
          null = WINDOWS ? 'NUL' : '/dev/null'
          {:AccessLog => [], :Logger => WEBrick::Log::new(null, 7)}
        end
      end
      
      helpers { include Helpers }
      extend Routes
      routes
    end
  end
end
