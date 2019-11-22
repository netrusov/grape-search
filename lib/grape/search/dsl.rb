# frozen_string_literal: true

# @api private
module Grape
  module Search
    class DSL
      def initialize(registry)
        @registry = registry.transform_values { |value| value[:options] }
        define_methods
      end

      def apply
        @registry.each do |entry, options|
          block = proc do
            method = options.delete(:required) ? :requires : :optional
            public_send(method, entry, options)
          end

          yield block
        end
      end

      private

      def define_methods
        @registry.keys.each do |entry|
          define_singleton_method entry do |**overrides|
            @registry[entry] = @registry[entry].merge(overrides)
          end
        end
      end
    end
  end
end
