# frozen_string_literal: true

require 'grape/search/dsl'

module Grape
  module Search
    module Extensions
      module Parameters
        # @param klass [Grape::Search]
        # @param except [Symbol, Array<Symbol>]
        # @param only [Symbol, Array<Symbol>]
        # @return [void]
        def search(klass, except: nil, only: nil, &block)
          registry = klass.registry
          entries = registry.keys
          entries -= Array(except) if except
          entries &= Array(only) if only
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
