# frozen_string_literal: true

require 'dry-logic'
require 'forwardable'

require_relative '../../../predicate/foreign/engine'
require_relative 'adapter'

module Lite
  module Validation
    module Validator
      module Adapters
        module Predicates
          module Dry
            class Builder
              def initialize(error_adapter, arity, severity: :dispute)
                @error_adapter = error_adapter
                @arity = arity
                @severity = severity
              end

              def call(&block)
                rule = ::Dry::Logic::Builder.call(&block)

                Predicate::Foreign::Variant.new(rule, adapter_instance)
              end

              def severity(severity)
                @severity = severity
                self
              end

              private

              attr_reader :error_adapter, :arity

              def adapter_instance
                Adapter.instance(error_adapter, arity, @severity)
              end
            end
          end
        end
      end
    end
  end
end
