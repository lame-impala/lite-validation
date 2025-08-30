# frozen_string_literal: true

require 'lite/data'
require 'forwardable'

module Lite
  module Validation
    module Validator
      module Coordinator
        class Instance
          extend Forwardable

          Lite::Data.define(self, kwargs: %i[interface validation_error final_error])

          def_delegator :interface, :failure
          def_delegator :interface, :success
          def_delegator :interface, :none
          def_delegator :interface, :some
          def_delegator :interface, :handle_result
          def_delegator :validation_error, :internal_error
          def_delegator :validation_error, :structured_error

          def build_final_error(result)
            final_error.build(result)
          end
        end
      end
    end
  end
end
