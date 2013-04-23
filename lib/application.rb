module Sword
  require 'sinatra/base'
  require 'psych'

  @settings = Psych.load_file './settings.yml'
  @settings[:gems].each do |g|
    begin require g
    rescue LoadError; next end
  end

  class Application < Sinatra::Base
    def version; @settings[:version] end
    # This piece of code is from Sinatra,
    # tweaked a bit to silent Thin server
    # and add Sword version and &c.
    def run! options = {}
      # Hook-up all gems that we will
      # probably need; open an issue
      # if this list is missing smth.
      set options
      handler = detect_rack_handler
      handler_name = handler.name.gsub(/.*::/, '')
      server_settings = settings.respond_to?(:server_settings) ? settings.server_settings : {}
      handler.run self, server_settings.merge(Port: port, Host: bind) do |server|
        $stderr.puts ">> Sword #{@settings[:version]} at your service!",
        "   http://localhost:#{port} to see your project.",
        "   CTRL+C to stop."
        [:INT, :TERM].each { |s| trap(s) { quit!(server, handler_name) } }
        server.silent = true
        server.threaded = settings.threaded
        set :running, true
        yield server if block_given?
      end
    rescue Errno::EADDRINUSE, RuntimeError
      $stderr.puts "!! Another instance of Sword is running.\n"
    end

    def quit! server, handler_name
      server.stop!
      $stderr.print "\n"
    end
    # Use the configuration file and inject
    # all the settings into stylesheet
    # hash called `sassy`
    Compass.add_project_configuration './compass.rb'
    sassy = Compass.sass_engine_options

    disable :show_exceptions # show `error.erb`
    set :port, 1111 # at localhost:1111
    set :views, '.' # Structure-agnostic
    set :public_folder, settings.views

    error do
      @error = env['sinatra.error']
      erb :error, :views => '.'
    end

    get '/favicon.ico' do
      send_file './favicon.ico'
    end

    get '/*.css' do |style|
      return send_file "#{style}.css" if File.exists? "#{style}.css"
      @settings[:styles].each do |k,v| v.each do |e| # for `extension`
        # Iterate through extensions and find the engine you need.
        return send k, style.to_sym, sassy if File.exists? "#{style}.#{e}"
      end end
      # If none, then raise an exception.
      raise "Stylesheet not found"
    end

    get '/*.js' do |script|
      return send_file "#{script}.js" if File.exists? "#{script}.js"
      @settings[:scripts].each do |k,v| v.each do |e|
        return send k, script.to_sym if File.exists? "#{script}.#{e}"
      end end
      raise "Script not found"
    end

    get '/' do
      # Call /index, the same shit
      call env.merge('PATH_INFO' => "/index")
    end

    get '/*/?' do |page|
      %w[html htm].each do |e|
        # This is specially for dumbasses who use .htm extension.
        # If you know another ultra-dumbass html extension, let me know.
        return send_file "#{page}.#{e}" if File.exists? "#{page}.#{e}"
      end
      @settings[:pages].each do |k,v| v.each do |e|
        # If Slim, then prettify the code so it is OK to read
        return send k, page.to_sym, pretty: true if File.exists? "#{page}.#{e}"
      end end
      # Is it an index? Call it recursively.
      raise "Page not found" if page =~ /index/
      call env.merge('PATH_INFO' => "/#{page}/index") 
    end
  end
end
