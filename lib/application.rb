module Sword
  # Hook-up all gems that we will probably need
  $settings[:gems].concat(@list || []).each do |lib|
    if lib.instance_of? Hash # Take the first possible variant if there are any
      lib.values.flatten.each { |var| begin require var; break rescue LoadError; next end } 
    else begin require lib; rescue LoadError; end end # Else, just require it
  end

  class Application < Sinatra::Base
    class << self
    # This piece of code is from Sinatra,
    # tweaked a bit to silent Thin server
    # and add Sword version and &c.
      def run!
        port = $port || 1111
        handler = detect_rack_handler
        server_settings = settings.respond_to?(:server_settings) ? settings.server_settings : {}
        handler.run self, server_settings.merge(Port: port, Host: bind) do |server|
          STDERR.print ">> Sword #{$settings[:version]} at your service!\n" +
          "   http://localhost:#{port} to see your project.\n" +
          "   CTRL+C to stop.\n"
          [:INT, :TERM].each { |s| trap(s) { quit! server, handler.name.gsub(/.*::/, '') } }
          server.threaded = settings.threaded
          server.silent = true unless @debug
          set :running, true
          yield server if block_given?
        end
      rescue Errno::EADDRINUSE, RuntimeError
        STDERR.puts "!! Another instance of Sword is running.\n"
      end
      def quit! server, handler_name
        server.stop!
        STDERR.print "\n"
      end
    end

    if defined? Compass
      Compass.add_project_configuration "#{$library}/compass.rb"
      compass = Compass.sass_engine_options
    end

    disable :show_exceptions # show `error.erb`
    set :views, $directory || '.' # Structure-agnostic
    set :public_folder, settings.views

    error do
      @error = env['sinatra.error']
      erb :error, :views => $library
    end

    get('/favicon.ico') { send_file "#{$library}/favicon.ico" }

    helpers do def parse thing, variable, to = nil, options = {}
      return send_file "#{thing}.#{to}" if to and File.exists? "#{thing}.#{to}"
      $settings[variable + 's'].map { |e| e.instance_of?(String) ? {e => [e]} : e }.each do |language|
        language.each do |engine, from| from.each do |xxx|
          # Iterate through extensions and find the engine you need.
          return send engine, thing.to_sym, options if File.exists? "#{thing}.#{xxx}"
        end end
      end
    end end

    get '/*.css' do |style|
      parse style, 'style', 'css', (compass || {})
      # If none, then raise an exception.
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
        return send_file "#{page}.#{xxx}" if File.exists? "#{page}.#{xxx}"
      end
      parse page, 'page', nil, {:pretty => true}
      raise 'Page not found' if page =~ /index/
      call env.merge('PATH_INFO' => "/#{page}/index") 
    end
  end
end
