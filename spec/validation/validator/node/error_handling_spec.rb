# frozen_string_literal: true

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Helpers::CallForeign do
          include Ruling::Constructors

          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: { foo: 'BAR' }
            )
          end
          let(:value) { { foo: 'FOO' } }
          let(:valid) { root }

          let(:expected_error_attributes) do
            { code: :execution_error, message: 'E!', data: { error_class: 'RuntimeError' } }
          end

          describe '#validate' do
            context 'when block raises' do
              it 'refutes the node' do
                expect(valid.validate(:foo) { raise 'E!' }.to_result.failure.dig(:children, :foo, :errors))
                  .to contain_exactly(have_attributes(expected_error_attributes))
              end
            end
          end

          describe '#at' do
            context 'when block raises' do
              it 'refutes the node' do
                expect(valid.at(:foo) { raise 'E!' }.to_result.failure.dig(:children, :foo, :errors))
                  .to contain_exactly(have_attributes(expected_error_attributes))
              end
            end
          end

          describe '#each_at' do
            context 'when block raises' do
              it 'refutes the node' do
                # rubocop:disable Lint/UnreachableLoop
                expect(valid.each_at { raise 'E!' }.to_result.failure.dig(:children, :foo, :errors))
                  .to contain_exactly(have_attributes(expected_error_attributes))
                # rubocop:enable Lint/UnreachableLoop
              end
            end
          end

          describe '#with_context' do
            context 'when block raises' do
              it 'refutes the node' do
                expect(valid.with_context({ foo: 'BAR' }) { raise 'E!' }.to_result.failure.dig(:errors))
                  .to contain_exactly(have_attributes(expected_error_attributes))
              end
            end

            context 'when block returns other object than a validator' do
              it 'raises error' do
                expect { valid.with_context({ foo: 'BAR' }) { Object.new } }
                  .to raise_error(Error, /Validator expected, got: #<Object:0x[0-9a-f]+>/)
              end
            end
          end

          describe '#with_valid' do
            context 'when block raises' do
              it 'refutes the node' do
                expect(valid.with_valid { raise 'E!' }.to_result.failure.dig(:errors))
                  .to contain_exactly(have_attributes(expected_error_attributes))
              end
            end
          end
        end
      end
    end
  end
end
