require 'sinatra/base'

class Sword < Sinatra::Base
  require 'psych'
  engines = Psych.load_file File.dirname(__FILE__) + '/engines.yml'

  %w[haml erb compass susy
  sass less liquid redcloth rdoc/markup slim
  markaby creole coffee-script].each do |g|
    begin require g
    rescue LoadError; next end
  end

  %w[redcarpet rdiscount bluecloth
  kramdown maruku].each do |g|
    begin require g; break
    rescue LoadError; next end
  end

  def self.version; "0.1.0" end
  set :views, '.'
  set :public_folder, settings.views
  set :port, 1111

  get '/favicon.ico' do
    send_file File.dirname(__FILE__) + "/../favicon.ico"
  end

  get '/*.css' do |style|
    content_type 'text/css', charset: 'utf-8'
    return send_file "#{style}.css" if File.exists? "#{style}.css"
    engines['styles'].each do |k,v| v.each do |e| # for extension
      return send k, style.to_sym, Compass.sass_engine_options
        .merge(line_comments: false) if File.exists? "#{style}.#{e}"
    end; end
  end

  get '/*.js' do |script|
    content_type 'application/x-javascript', charset: 'utf-8'
    return send_file "#{script}.js" if File.exists? "#{script}.js"
    engines['scripts'].each do |k,v| v.each do |e| # for extension
      return send k, script.to_sym if File.exists? "#{script}.#{e}"
    end; end
  end

  get '/' do
    redirect '/index'
  end

  get '/*/?' do |page|
    return send_file "#{page}.html" if File.exists? "#{page}.html"
    return send_file "#{page}.htm" if File.exists? "#{page}.htm"
    engines['pages'].each do |k,v| v.each do |e| # for extension
      return send k, page.to_sym if File.exists? "#{page}.#{e}"
    end; end
    raise "Page doesn't exist"
  end
end
