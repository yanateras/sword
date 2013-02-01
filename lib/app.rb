require 'sinatra/base'
require 'psych'

class Sword < Sinatra::Base
  def self.version; "0.2.0" end
  dir = File.dirname(__FILE__)
  engine = Psych.load_file "#{dir}/engine.yml"
  # Hook-up all gems that we will
  # probably need; open an issue
  # if this list is missing smth.
  engine['gems'].each do |g|
    begin require g
    rescue LoadError; next end
  end

  engine['markdown'].each do |m|
    begin require m; break
    rescue LoadError; next end
  end

  disable :show_exceptions

  error do
    @error = env['sinatra.error']
    erb :error, views: "#{dir}/../"
  end

  get '/favicon.ico' do
    send_file "#{dir}/../favicon.ico"
  end

  set :views, '.'
  set :public_folder, settings.views
  set :port, 1111

  get '/*.css' do |style|
    return send_file "#{style}.css" if File.exists? "#{style}.css"
    engine['styles'].each do |k,v| v.each do |e| # for extension
      return send k, style.to_sym, Compass.sass_engine_options
        .merge(line_comments: false, cache: false) if File.exists? "#{style}.#{e}"
    end; end
    raise "Stylesheet not found"
  end

  get '/*.js' do |script|
    return send_file "#{script}.js" if File.exists? "#{script}.js"
    engine['scripts'].each do |k,v| v.each do |e| # for extension
      return send k, script.to_sym if File.exists? "#{script}.#{e}"
    end; end
    raise "Script not found"
  end

  get '/' do
    call env.merge('PATH_INFO' => "/index")
  end

  get '/*/?' do |page|
    %w[html htm].each do |e|
      # This is specially for dumbasses who use .htm extension
      # If you know another ultra-dumbass html extension, let me know.
      return send_file "#{page}.#{e}" if File.exists? "#{page}.#{e}"
    end
    engine['pages'].each do |k,v| v.each do |e| # for extension
      return send k, page.to_sym, pretty: true if File.exists? "#{page}.#{e}"
    end; end
    # Is it an index? Call it recursively.
    raise "Page not found" if page =~ /index/
    call env.merge('PATH_INFO' => "/#{page}/index") 
  end
end
