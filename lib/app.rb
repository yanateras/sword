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
  set :views, '.'
  set :public_folder, '.'
  set :port, 1111

  get '/favicon.ico' do
    send_file File.dirname(__FILE__) + "/../favicon.ico"
  end

  get '/*.css' do |style|
    content_type 'text/css', charset: 'utf-8'
    # If there is a CSS, take it.
    # Otherwise, use SASS.
    return send_file "#{style}.css" if File.exists? "#{style}.css"
    return less style.to_sym if File.exists? "#{style}.less"
    # SASS/Compass
    sass style.to_sym, Compass.sass_engine_options
      .merge(style: :compressed)
  end

  get '/*.js' do |script|
    content_type 'application/x-javascript', charset: 'utf-8'
    # If there is a JS, take it.
    # Otherwise, use CoffeeScript.
    return send_file script if File.exists? script
    coffee js.to_sym
  end

  get '/' do
    redirect '/index'
  end

  get '/*/?' do |page|
    return File.read "#{page}.html" if File.exists? "#{page}.html"
    return haml page.to_sym if File.exists? "#{page}.haml"
    return slim page.to_sym if File.exists? "#{page}.slim"
  end
end
