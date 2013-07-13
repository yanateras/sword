require 'sword/boot/gems'

module Sword
  module Boot
    module Loader
      def load(options = {})
        options = {
          :directory => Dir.pwd,
          :port => 1111,
          :gems => parse_yaml('./gems'),
          :gemlist => parse_yaml("#{Dir.home}/.sword"),
          :engines => "./engines"
        }.merge(options)

        include_gems settings['gems']['general']
        include_gems options[:gemlist]
        include_gems settings['gems']['unix'] unless Windows::PLATFORM

        Applicaton.run!(options)
      end

      include Gems

      def parse_engine(file)
        YAML.load_file(file).map { |l| l.map { |e| String === e ? {e => [e]} : e } }
      end

      def load_compass(file = "#{LIBRARY}/compass.rb")
        return {} unless defined? Compass
        Compass.add_project_configuration @compass_file
        Compass.sass_engine_options
      end
      
      def parse_yaml(file)
        require 'yaml' unless defined? YAML
        YAML.load_file file
      end

      def install_gems(list)
        exec 'gem install ' +
        list.map { |n| n.respond_to?(:first) ? n.first : n }.delete_if { |g| g['/'] } * ' '
      end

      def append_to_include(name)
        open(LOAD_FILE, 'a') { |f| f.puts name }
        puts "#{g} will be loaded next time you run Sword."
      end
    end
  end
end
