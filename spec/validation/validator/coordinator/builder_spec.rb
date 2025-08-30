# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../lib/lite/validation/validator/coordinator/builder'

module Lite
  module Validation
    module Validator
      module Coordinator
        class Builder
          RSpec.describe '#build' do
            context 'when builder is invalid' do
              it 'raises error' do
                expected_message = <<~MESSAGE.chomp
                  Builder invalid: \
                  interface_adapter: value_missing, \
                  final_error_adapter: value_missing, \
                  validation_error_adapter: value_missing
                MESSAGE

                expect { Builder.define {}.build }
                  .to raise_error(Error, expected_message)
              end
            end

            context 'when errors adapter is invalid' do
              it 'raises error' do
                expected_message = <<~MESSAGE.chomp
                  Builder invalid: \
                  interface_adapter: value_missing, \
                  final_error_adapter: value_missing, \
                  validation_error_adapter.structured_error: value_missing
                MESSAGE

                expect { Builder.define { validation_error_adapter {} }.build }
                  .to raise_error(Error, expected_message)
              end
            end
          end
        end
      end
    end
  end
end
