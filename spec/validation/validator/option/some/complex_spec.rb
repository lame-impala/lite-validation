# frozen_string_literal: true

require 'spec_helper'
require 'forwardable'

require_relative '../../../../../lib/lite/validation/validator/option'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          # rubocop:disable Security/Eval
          eval(ReadmeHelper.snippet!(:implement_custom_wrapper))
          # rubocop:enable Security/Eval

          RSpec.describe Complex do
            context 'with custom wrapper' do
              let(:wrapped) { described_class.instance(relation) }
              let(:relation) { NotArray.new(array) }
              let(:array) { [1, 2, 3] }

              it 'fetches the value' do
                expect(wrapped.fetch(1).unwrap).to eq(2)
              end

              it 'enables reduction of the underlying collection' do
                expect(wrapped.reduce(0) { |acc, (value, _idx)| acc + value }).to eq(6)
              end
            end
          end
        end
      end
    end
  end
end
