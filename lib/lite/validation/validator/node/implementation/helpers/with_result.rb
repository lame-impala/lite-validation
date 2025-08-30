# frozen_string_literal: true

require_relative '../../../ruling'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Helpers
            module WithResult
              def self.with_result(validator, result)
                return validator if result.equal?(validator.result)

                validator.send(:with, result: result)
              end
            end
          end
        end
      end
    end
  end
end
