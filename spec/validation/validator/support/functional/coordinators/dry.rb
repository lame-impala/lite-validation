# frozen_string_literal: true

require_relative '../../../../../../lib/lite/validation/validator/coordinator'
require_relative '../../../../../../lib/lite/validation/validator/adapters/interfaces/dry'
require_relative '../../../../../../lib/lite/validation/validator/adapters/predicates/dry'

require_relative '../../../../support/readme_helper'

module Lite
  module Validation
    module Validator
      module Support
        module Functional
          module Coordinators
            module Dry
              Flat = Coordinator::Builder.define do
                interface_adapter Adapters::Interfaces::Dry
                validation_error_adapter do
                  structured_error do |code, message: nil, data: nil|
                    StructuredError::Record.instance(code, message: message, data: data)
                  end

                  internal_error do |id, message: nil, data: nil|
                    message ||= case id
                                when :value_missing then 'Value is missing'
                                when :not_iterable then 'Value is not iterable'
                    end

                    structured_error(id, message: message, data: data)
                  end
                end
                final_error_adapter Coordinator::Errors::Flat
              end

              # rubocop:disable Security/Eval
              eval(ReadmeHelper.snippet!(:coordinator_dry_hierarchical))
              # rubocop:enable Security/Eval

              Dry = Coordinator::Builder.define do
                interface_adapter Adapters::Interfaces::Dry
                validation_error_adapter do
                  structured_error do |code, message: nil, data: nil|
                    StructuredError::Record.instance(code, message: message, data: data)
                  end
                  internal_error do |id, message: nil, data: nil|
                    message ||= case id
                                when :value_missing then 'Value is missing'
                                when :not_iterable then 'Value is not iterable'
                    end

                    structured_error(id, message: message, data: data)
                  end
                end
                final_error_adapter Coordinator::Errors::Dry
              end
            end
          end
        end
      end
    end
  end
end
