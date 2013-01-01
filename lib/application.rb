module Sword
  require 'sinatra/base'
  # Hook-up all gems that we will probably need
  PARSING['gems'].concat(File.exists?(REQUIRED) ? File.read(REQUIRED).split("\n") : []).each do |lib|
    if lib.instance_of? Hash # Take the first possible variant if there are any
      lib.values.flatten.each { |var| begin require var; break rescue LoadError; next end } 
    else begin require lib; rescue LoadError; end end # Else, just require it
  end

  class Application < Sinatra::Base
    # This piece of code is from Sinatra,
    # tweaked a bit to silent Thin server
    # and add Sword version and &c.
    class << self
      def run!
        port = $port || 1111
        server_settings = settings.respond_to?(:server_settings) ? settings.server_settings : {}
        detect_rack_handler.run self, server_settings.merge(Port: port, Host: bind) do |server|
          STDERR.print ">> Sword #{VERSION} at your service!\n" +
          "   http://localhost:#{port} to see your project.\n" +
          "   CTRL+C to stop.\n"
          [:INT, :TERM].each { |s| trap(s) { quit! server } }
          server.threaded = settings.threaded
          server.silent = true unless $debug
          set :running, true
          yield server if block_given?
        end
      rescue Errno::EADDRINUSE, RuntimeError
        STDERR.print "!! Another instance of Sword is running.\n"
      end
      def quit! server
        server.stop!
        STDERR.print "\n"
      end
    end

    if defined? Compass
      Compass.add_project_configuration "#{LIBRARY}/compass.rb"
      compass = Compass.sass_engine_options
    end

    disable :show_exceptions # show `error.erb`
    set :views, $directory || '.' # Structure-agnostic
    set :public_folder, settings.views

    error do
      @error = env['sinatra.error']
      erb :error, :views => LIBRARY
    end

    get('/favicon.ico') { send_file "#{LIBRARY}/favicon.ico" }
    # 8 916 844 18 68

    helpers do def parse shadow, variable, output = nil, options = {}
      return send_file "#{shadow}.#{output}" if output and File.exists? "#{shadow}.#{output}"
      PARSING[variable + 's'].map { |e| e.instance_of?(String) ? {e => [e]} : e }.each do |language|
        language.each do |engine, extension| extension.each do |x|
          # Iterate through extensions and find the engine you need.
          return send engine, shadow.to_sym, options if File.exists? "#{shadow}.#{x}"
        end end
      end
    end end

    get '/*.css' do |style|
      parse style, 'style', 'css', (compass || {})
      raise 'Stylesheet not found'
    end

    get '/*.js' do |script|
      parse script, 'script', 'js'
      raise 'Script not found'
    end

    get '/' do
      # Call /index, the same shit
      call env.merge 'PATH_INFO' => '/index'
    end

    get '/*/?' do |page|
      %w[html htm].each do |xxx|
        # This is specially for dumbasses who use .htm extension.
        # If you know another ultra-dumbass html extension, let me know.
        return send_file "#{page}.#{xxx}" if File.exist? "#{page}.#{xxx}"
      end
      parse page, 'page', nil, {:pretty => true}
      raise 'Page not found' if page =~ /index$/
      call env.merge('PATH_INFO' => "/#{page}/index") 
    end
  end
end
