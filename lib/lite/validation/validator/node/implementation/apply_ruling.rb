# frozen_string_literal: true

require_relative '../../../error'
require_relative 'helpers/with_result'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module ApplyRuling
            def self.apply_ruling(validator, path: nil)
              updated, _meta = validator.result.navigate(*path) do |result|
                applied = yield result
                validator.merge_strategy.transform_result(applied, validator, path)
              end
              Helpers::WithResult.with_result(validator, updated)
            end

            def self.structured_error(coordinator, error, **opts)
              case [error, opts]
              in [StructuredError, {}] then error
              in [Symbol, { ** }] then coordinator.structured_error(error, **opts)
              else raise Error::Fatal, "Unexpected first argument: #{error.inspect}"
              end
            end

            def commit(value, at: nil)
              ApplyRuling.apply_ruling(self, path: at) { _1.commit(value) }
            end

            def auto_commit(as:)
              Helpers::WithResult.with_result(self, result.auto_commit(as: as))
            end

            def dispute(error, at: nil, **opts)
              ApplyRuling.apply_ruling(self, path: at) do |result|
                result.dispute(ApplyRuling.structured_error(coordinator, error, **opts))
              end
            end

            def refute(error, at: nil, **opts)
              ApplyRuling.apply_ruling(self, path: at) do |result|
                result.refute(ApplyRuling.structured_error(coordinator, error, **opts))
              end
            end
          end
        end
      end
    end
  end
end
