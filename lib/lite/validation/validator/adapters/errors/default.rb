# frozen_string_literal: true

require_relative '../../../structured_error/record'
require_relative '../../coordinator/errors/flat'

module Lite
  module Validation
    module Validator
      module Adapters
        module Errors
          module Default
            def self.internal_error(id, message: nil, data: nil)
              structured_error(id, message: message, data: data)
            end

            def self.structured_error(code, message: nil, data: nil)
              StructuredError::Record.instance(code, message: message, data: data)
            end
          end
        end
      end
    end
  end
end
