# frozen_string_literal: true

require_relative '../../../../../../lib/lite/validation/validator/adapters/interfaces/dry'
require_relative 'common'

module Lite
  module Validation
    module Validator
      module Support
        module Unit
          module Coordinators
            module Dry
              interface_adapter = Adapters::Interfaces::Dry

              Flat = Coordinator::Instance.new(
                interface: interface_adapter,
                validation_error: Common,
                final_error: Coordinator::Errors::Flat
              )

              Hierarchical = Coordinator::Instance.new(
                interface: interface_adapter,
                validation_error: Common,
                final_error: Coordinator::Errors::Hierarchical
              )
            end
          end
        end
      end
    end
  end
end
