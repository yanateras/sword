module Sword
  module Core
    module Routes
      HTML = %w[html htm xhtml xht dhtml dhtm]
      
      # Runs all methods starting with inject_
      # 
      def routes
        methods.delete_if { |m| not m.to_s.start_with? 'inject_' }.each { |m| send m } 
      end

      # In case of error, show your user a detailed log
      #
      # @todo Still doesn’t work good. Bad text, bad console
      #   error handling, need more interface solutions.
      def inject_error
        error do
          @error = env['sinatra.error']
          erb :error, :views => LIBRARY
        end
      end

      # If no favicon specified, show Sword icon
      # 
      def inject_favicon
        get '/favicon.ico' do
          send_file "#{LIBRARY}/favicon.ico"
        end
      end

      # Synonymize /catalog_name with /catalog_name/index
      # unless there is a catalog_name.* file
      # 
      def inject_index
        get '/' do
          # Call /index, the same shit
          # TODO: for any level
          call env.merge 'PATH_INFO' => '/index'
        end
      end

      def inject_main
        parse_styles
        parse_scripts
        synonymize_html
        parse_templates
      end

      def synonymize_html
        get(/(.+?)\.(#{ HTML * '|' })/) do |route, _|
          call env.merge 'PATH_INFO' => route
        end
      end

      def parse_styles
        parse @styles, '/*.css', Boot::Loader.load_compass
      end

      def parse_scripts
        parse @scripts, '/*.js'
      end

      def parse_templates
        parse @templates, '/*/?' do |page|
          HTML.each { |extension| return erb File.read(file = "#{page}.#{extension}") if File.exists? file }
          raise NotFound if page =~ /\/index$/ or not defined? env
          call env.merge({'PATH_INFO' => "/#{page}/index"})
        end
      end
    end
  end
end
