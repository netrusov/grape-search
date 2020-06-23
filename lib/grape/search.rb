# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'grape'

require 'grape/search/extensions/parameters'
require 'grape/search/version'

module Grape
  module Search
    extend ActiveSupport::Concern

    Boolean = Grape::API::Boolean

    included do
      class_attribute :registry, instance_writer: false, default: {}
    end

    class_methods do
      # @yield Default scope
      # @return [Proc]
      def default_scope(&block)
        @default_scope ||= block
      end

      # @param name [Symbol]
      # @param options [Hash] (see Grape::DSL::Parameters#requires)
      def search(name, **options, &block)
        registry[name] = { options: options, block: block }
      end
    end

    attr_reader :scope
    delegate :default_scope, to: :class

    # @param params [Hash]
    def initialize(params)
      @params = params&.symbolize_keys || {}
      @scope = default_scope.call
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
