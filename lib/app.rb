# Hook-up all gems that we will
# probably need; open an issue
# if this list is missing smth.
$engine['gems'].each do |g|
  begin require g
  rescue LoadError; next end
end

$engine['markdown'].each do |m|
  begin require m; break
  rescue LoadError; next end
end

require 'sinatra/base'

class Sword < Sinatra::Base
  require "#{$dir}/message"
  # Use the configuration file and inject
  # all the settings into stylesheet
  # hash called `sassy`
  Compass.add_project_configuration "#{$dir}/compass.rb"
  sassy = Compass.sass_engine_options

  disable :show_exceptions # show `error.erb`
  set :port, 1111 # at localhost:1111

  # Structure-agnostic:
  set :views, '.'
  set :public_folder, settings.views
  set :markdown, layout_engine: :slim # Do it better next time

  error do
    @error = env['sinatra.error']
    erb :error, views: $dir
  end

  get '/favicon.ico' do
    send_file "#{$dir}/favicon.ico"
  end

  get '/*.css' do |style|
    return send_file "#{style}.css" if File.exists? "#{style}.css"
    $engine['styles'].each do |k,v| v.each do |e| # for `extension`
      # Iterate through extensions and find the engine you need.
      return send k, style.to_sym, sassy if File.exists? "#{style}.#{e}"
    end; end
    # If none, then raise an exception.
    raise "Stylesheet not found"
  end

  get '/*.js' do |script|
    return send_file "#{script}.js" if File.exists? "#{script}.js"
    $engine['scripts'].each do |k,v| v.each do |e|
      return send k, script.to_sym if File.exists? "#{script}.#{e}"
    end; end
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
    $engine['pages'].each do |k,v| v.each do |e|
      # If Slim, then prettify the code so it is OK to read
      return send k, page.to_sym, pretty: true if File.exists? "#{page}.#{e}"
    end; end
    # Is it an index? Call it recursively.
    raise "Page not found" if page =~ /index/
    call env.merge('PATH_INFO' => "/#{page}/index") 
  end
end
