# frozen_string_literal: true

require_relative '../../../../../../lib/lite/validation/validator/coordinator/errors/flat'
require_relative '../../../../../../lib/lite/validation/validator/coordinator/errors/hierarchical'
require_relative '../../../../../../lib/lite/validation/validator/coordinator/instance'
require_relative '../../../../../../lib/lite/validation/structured_error/record'

module Lite
  module Validation
    module Validator
      module Support
        module Unit
          module Coordinators
            module Common
              def self.internal_error(id, message: nil, data: nil)
                message ||= case id
                            when :value_missing then 'Value is missing'
                            when :not_iterable then 'Value is not iterable'
                end

                structured_error(id, message: message, data: data)
              end

              def self.structured_error(id, message: nil, data: nil)
                StructuredError::Record.instance(id, message: message, data: data)
              end
            end
          end
        end
      end
    end
  end
end
