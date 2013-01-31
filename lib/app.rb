require 'sinatra/base'

%w[haml erb builder nokogiri
sass less liquid redcloth rdoc
radius markaby creole coffee-script].each do |g|
  begin
    require g
  rescue LoadError; next end
end

# Markdown
%w[redcarpet rdiscount bluecloth
kramdown maruku].each do |g|
  begin
    require g
    break
  rescue LoadError; next end
end

class Sword < Sinatra::Base
  set :scripts, 'scripts'
  set :styles, 'styles'
  set :views, 'templates'
  set :public_folder, 'other'
  set :port, 1111

  get '/*.css' do |css|
    content_type 'text/css', :charset => 'utf-8'
    # If there is a CSS, take it.
    # Otherwise, use SASS.
    style = "#{settings.styles}/#{css}"
    return File.read "#{style}.css" if File.exists? "#{style}.css"
    return less style.to_sym if File.exists? "#{style}.less"
    # SASS/Compass
    sass css.to_sym, Compass.sass_engine_options
      .merge(views: settings.styles, style: :compressed)
  end

  get '/*.js' do |js|
    content_type 'application/x-javascript', :charset => 'utf-8'
    # If there is a JS, take it.
    # Otherwise, use CoffeeScript.
    script = "#{settings.scripts}/#{js}.js"
    return File.read script if File.exists? script
    coffee js.to_sym, views: settings.scripts
  end

  get '/' do
    slim :index
  end

  # Slim & HTML
  get '/*/?' do |page|
    template = "#{settings.views}/#{page}"
    # Make HTML in `templates` folder possible.
    return File.read "#{template}.html" if File.exists? "#{template}.html"
    return haml page.to_sym if File.exists? "#{template}.haml"
    slim page.to_sym
  end
end
