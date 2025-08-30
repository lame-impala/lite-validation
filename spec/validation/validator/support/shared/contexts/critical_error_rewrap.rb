# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      RSpec.shared_context 'with critical error rewrap' do
        let(:critical_error_rewrap) do
          lambda { |error, path|
            StructuredError::Record.instance(
              error.code,
              message: error.message,
              data: { path: path, original_data: error.data }
            )
          }
        end
      end
    end
  end
end
