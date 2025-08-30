# frozen_string_literal: true

require_relative '../../error'
require_relative 'abstract/variants'

module Lite
  module Validation
    module Validator
      module Predicate
        module Registry
          def self.register_predicate(key, predicate)
            raise Error, "Not a predicate: #{predicate}" unless predicate.is_a?(Predicate::Abstract::Variants)
            raise Error, "Key already taken: #{key}" if predicates.key?(key)

            predicates[key] = predicate
          end

          def self.predicate(key)
            raise Error, "Predicate not registered: #{key}" unless predicates.key?(key)

            predicates[key]
          end

          def self.predicates
            @predicates ||= {}
          end

          def self.register_adapter(key, engine)
            raise Error, "Key already taken: #{key}" if engines.key?(key)

            engines[key] = engine
          end

          def self.engine(key)
            raise Error, "Engine not registered: #{key}" unless engines.key?(key)

            engines[key]
          end

          def self.engines
            @engines ||= {}
          end
        end
      end
    end
  end
end
