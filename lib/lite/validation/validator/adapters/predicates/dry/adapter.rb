# frozen_string_literal: true

require 'forwardable'
require 'dry-logic'

require_relative '../../../predicate/foreign/adapter/input'
require_relative '../../../predicate/foreign/adapter/ruling'

module Lite
  module Validation
    module Validator
      module Adapters
        module Predicates
          module Dry
            class Adapter
              extend Forwardable

              Lite::Data.define(self, args: %i[error_adapter input_adapter ruling_adapter])

              def self.instance(error_adapter, arity, severity)
                new(
                  error_adapter,
                  Predicate::Foreign::Adapter::Input.instance(arity),
                  Predicate::Foreign::Adapter::Ruling.instance(severity)
                )
              end

              def_delegator :input_adapter, :pass_in
              def_delegator :ruling_adapter, :severity

              def to_ruling(result, rule, value)
                return Validator::Ruling::Pass() if result.success?

                ruling_adapter.to_ruling(error_adapter.call(rule, value))
              end

              def dispute
                severity == :dispute ? self : with(ruling_adapter: ruling_adapter.dispute)
              end

              def refute
                severity == :refute ? self : with(ruling_adapter: ruling_adapter.refute)
              end
            end
          end
        end
      end
    end
  end
end
