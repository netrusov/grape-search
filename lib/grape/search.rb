# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'grape'

require 'grape/search/extensions/parameters'
require 'grape/search/version'

module Grape
  module Search
    extend ActiveSupport::Concern

    included do
      class_attribute :default_scope
    end

    class_methods do
      # @api private
      def registry
        @registry ||= {}
      end

      # @param name [Symbol]
      # @param options [Hash] (see Grape::DSL::Parameters#requires)
      def search(name, **options, &block)
        registry[name] = { options: options, block: block }
      end
    end

    attr_reader :scope
    delegate :registry, to: :class

    # @param params [Hash]
    def initialize(params)
      @params = params&.symbolize_keys || {}
      @scope = default_scope
    end

    # Returns filtered scope
    def result
      @result ||= begin
        @params.each do |key, value|
          next unless registry.key?(key)

          @scope = instance_exec(value, &registry.dig(key, :block))
        end

        @scope
      end
    end
  end
end

Grape::Validations::ParamsScope.class_exec do
  include Grape::Search::Extensions::Parameters
end
