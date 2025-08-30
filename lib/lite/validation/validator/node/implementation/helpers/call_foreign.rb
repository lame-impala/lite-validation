# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Helpers
            module CallForeign
              def self.call_foreign(result, coordinator, &block)
                block.call
              rescue Error::Fatal
                raise
              rescue StandardError => e
                rescue_execution_error(result, coordinator, e)
              end

              def self.rescue_execution_error(result, coordinator, error)
                error = coordinator.internal_error(
                  :execution_error,
                  message: error.message, data: { error_class: error.class.name }
                )
                result.refute(error)
              end
            end
          end
        end
      end
    end
  end
end
