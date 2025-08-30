# frozen_string_literal: true

require_relative 'call_foreign'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Helpers
            module YieldValidator
              def self.yield_child(parent, child, block)
                updated, meta = yield_validator(child, block)
                transformed = parent.merge_strategy.transform_result(updated, parent, child.path)
                [transformed, meta]
              end

              def self.yield_validator(validator, block)
                validator = ensure_valid_result!(validator, block.call(validator))

                [validator.result, validator.context]
              rescue Error::Fatal
                raise
              rescue StandardError => e
                [
                  CallForeign.rescue_execution_error(validator.result, validator.coordinator, e),
                  validator.context
                ]
              end

              def self.ensure_valid_result!(origin, result)
                ensure_validator!(result)
                Implementation::Identity.ensure_identical! origin, result

                result
              end

              def self.ensure_validator!(candidate)
                return if candidate.is_a?(Abstract::Instance)

                raise Error::Fatal, "Validator expected, got: #{candidate.inspect}"
              end
            end
          end
        end
      end
    end
  end
end
