%w[haml erb builder nokogiri compass
sass less liquid redcloth rdoc slim
radius markaby creole coffee-script].each do |g|
  begin require g
  rescue LoadError; next end
end

%w[redcarpet rdiscount bluecloth
kramdown maruku].each do |g|
  begin require g; break
  rescue LoadError; next end
end

require 'sinatra/base'

class Sword < Sinatra::Base
  def self.version; "0.1.0" end
  set :scripts, 'scripts'
  set :styles, 'styles'
  set :views, 'templates'
  set :public_folder, 'other'
  set :port, 1111

  get '/favicon.ico' do
    send_file File.dirname(__FILE__) + "/../favicon.ico"
  end

  get '/*.css' do |css|
    content_type 'text/css', charset: 'utf-8'
    # If there is a CSS, take it.
    # Otherwise, use SASS.
    style = "#{settings.styles}/#{css}"
    return send_file "#{style}.css" if File.exists? "#{style}.css"
    return less style.to_sym if File.exists? "#{style}.less"
    # SASS/Compass
    sass css.to_sym, Compass.sass_engine_options
      .merge(views: settings.styles, style: :compressed)
  end

  get '/*.js' do |js|
    content_type 'application/x-javascript', charset: 'utf-8'
    # If there is a JS, take it.
    # Otherwise, use CoffeeScript.
    script = "#{settings.scripts}/#{js}.js"
    return send_file script if File.exists? script
    coffee js.to_sym, views: settings.scripts
  end

  get '/' do
    redirect '/index'
  end

  # Slim & HTML
  get '/*/?' do |html|
    template = "#{settings.views}/#{html}"
    # Make HTML in `templates` folder possible.
    return File.read "#{template}.html" if File.exists? "#{template}.html"
    return haml page.to_sym if File.exists? "#{template}.haml"
    slim html.to_sym
  end
end
