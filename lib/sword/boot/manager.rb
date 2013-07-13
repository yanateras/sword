module Sword
  module Boot
    class Manager
      def initialize(options, &block)
        @options = options
        return build if @options.delete(:build)
        return generate if @options.delete(:generate)
        return run
      end

      private

      include Loader

      def build
        require 'sword/builder'
        Builder.new(@options)
      end

      def generate
        require 'sword/generator'
        Generator.new(@options)
      end

      def run
        require 'sword/core/application'
        Core::Application.run!(@options)
      end
    end
  end
end
