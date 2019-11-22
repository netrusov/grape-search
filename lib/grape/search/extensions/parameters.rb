# frozen_string_literal: true

require 'grape/search/dsl'

module Grape
  module Search
    module Extensions
      module Parameters
        extend ActiveSupport::Concern

        # @param klass [Grape::Search]
        # @param options [Hash]
        # @option options :except [Symbol, Array<Symbol>]
        # @option options :only [Symbol, Array<Symbol>]
        # @return [void]
        def search(klass, **options, &block)
          registry = klass.registry
          entries = registry.keys
          entries -= Array(options[:except]) if options.key?(:except)
          entries &= Array(options[:only]) if options.key?(:only)
          registry = registry.slice(*entries)

          Grape::Search::DSL.new(registry).tap do |context|
            context.instance_exec(&block) if block_given?
            context.apply { |inner_block| instance_exec(&inner_block) }
          end
        end
      end
    end
  end
end
