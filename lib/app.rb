require 'sinatra/base'
require 'psych'

class Sword < Sinatra::Base
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
  error { send_file "#{dir}/../error.html" }
  get('/favicon.ico') { send_file "#{dir}/../favicon.ico" }

  def self.version; "0.1.0" end
  set :views, '.'
  set :public_folder, settings.views
  set :port, 1111

  get '/*.css' do |style|
    content_type 'text/css', charset: 'utf-8'
    return send_file "#{style}.css" if File.exists? "#{style}.css"
    engine['styles'].each do |k,v| v.each do |e| # for extension
      return send k, style.to_sym, Compass.sass_engine_options
        .merge(line_comments: false) if File.exists? "#{style}.#{e}"
    end; end
  end

  get '/*.js' do |script|
    content_type 'application/x-javascript', charset: 'utf-8'
    return send_file "#{script}.js" if File.exists? "#{script}.js"
    engine['scripts'].each do |k,v| v.each do |e| # for extension
      return send k, script.to_sym if File.exists? "#{script}.#{e}"
    end; end
  end

  get '/' do
    call env.merge('PATH_INFO' => '/index')
  end

  get '/*/?' do |page|
    %w[html htm].each do |e|
      # This is specially for dumbasses who use .htm extension
      # If you know another ultra-dumbass html extension, let me know.
      return send_file "#{page}.#{e}" if File.exists? "#{page}.#{e}"
    end
    engine['pages'].each do |k,v| v.each do |e| # for extension
      return send k, page.to_sym if File.exists? "#{page}.#{e}"
    end; end
    raise "Page doesn't exist"
  end
end
