module Sword
  class Loader
    extend Output
    class << self
      public

      def load(options = {})
        options = {
          :directory => Dir.pwd,
          :port => 1111,
          :gems => parse_yaml("#{LIBRARY}/gems.yml"),
          :gemlist => parse_yaml("#{Dir.home}/.sword"),
          :engines => "#{LIBRARY}/engines"
        }.merge(options)

        include_gems settings['gems']['general']
        include_gems options[:gemlist]
        include_gems settings['gems']['unix'] unless Windows::PLATFORM

        Applicaton.run!(options)
      end

      def parse_engine(file)
        YAML.load_file(file).map { |l| l.map { |e| String === e ? {e => [e]} : e } }
      end

      def install_gems(list)
        exec 'gem install ' +
        list.map { |n| n.respond_to?(:first) ? n.first : n }.delete_if { |g| g['/'] } * ' '
      end

      def append_to_include(name)
        open(LOAD_FILE, 'a') { |f| f.puts name }
        puts "#{g} will be loaded next time you run Sword."
      end

      def load_compass(file = "#{LIBRARY}/compass.rb")
        return {} unless defined? Compass
        Compass.add_project_configuration @compass_file
        Compass.sass_engine_options
      end
      
      private

      def parse_yaml(file)
        require 'yaml' unless defined? YAML
        YAML.load_file file
      end

      def include_first(options)
        options.values.first.each do |option|
          begin
            debug option + '.' * (15 - option.length), '  '
            require option
            debug "OK\n"
            break
          rescue LoadError
            debug "Fail\n"
            next
          end
        end
      end

      def include_only(name)
        begin
          debug lib + '.' * (15 - lib.length), '  '
          require lib
          debug "OK\n"
        rescue LoadError
          debug "Fail\n"
        end
      end

      def include_gems(list)
        debug "Including gems:\n", ' '
        list.each { |l| Hash === l ? include_first(l) : include_only(l) }
      end
    end
  end
end
