# frozen_string_literal: true

require_relative 'builder'
require_relative '../../../predicate/registry'

module Lite
  module Validation
    module Validator
      module Adapters
        module Predicates
          module Dry
            class Engine < Predicate::Foreign::Engine
              def self.instance(error_adapter)
                new error_adapter
              end

              def build_contextual(keys, context, &block)
                definite = block.call(Builder.new(error_adapter, keys.length), context)
                Predicate::Foreign::Variants.new(definite: definite)
              end

              def build(keys, severity: :dispute, &block)
                definite = Builder.new(error_adapter, keys.length, severity: severity).call(&block)
                Predicate::Foreign::Variants.new(definite: definite)
              end
            end
          end
        end
      end
    end
  end
end
