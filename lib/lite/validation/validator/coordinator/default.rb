# frozen_string_literal: true

require_relative '../adapters/errors/default'
require_relative '../adapters/interfaces/default'
require_relative 'instance'

module Lite
  module Validation
    module Validator
      module Coordinator
        class Default < Instance
          def self.instance(error_building_strategy)
            monads = Adapters::Interfaces::Default
            errors = Adapters::Errors::Default
            new interface: monads, validation_error: errors, final_error: error_building_strategy
          end

          def_delegator :validation_error, :structured_error

          def build_final_error(result)
            errors = final_error.build(result)
            message = errors.flat_map do |(key, errors)|
              key.empty? ? errors.join(', ') : "#{key}: #{errors.map(&:code).join(', ')}"
            end.join(', ')

            structured_error(:invalid, message: message, data: errors)
          end
        end
      end
    end
  end
end
