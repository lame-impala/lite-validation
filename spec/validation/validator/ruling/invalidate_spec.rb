# frozen_string_literal: true

require_relative '../../../../lib/lite/validation/validator/ruling'
require_relative '../../../../lib/lite/validation/structured_error/record'
require_relative '../../../../lib/lite/validation/validator/coordinator/errors/flat'
require_relative '../../../../lib/lite/validation/validator/adapters/errors/default'

require_relative '../support/unit/result'

module Lite
  module Validation
    module Validator
      module Ruling
        RSpec.describe Ruling::Invalidate do
          context 'with structured error' do
            let(:error) { StructuredError::Record.instance(:invalid) }

            describe '#refute' do
              context 'with Invalidate' do
                let(:ruling) { Ruling::Invalidate(error) }

                it 'returns Refute' do
                  expect(ruling.refute).to be_a(Refute)
                end
              end

              context 'with Invalidate::Raw' do
                let(:ruling) { Ruling::Invalidate(:invalid) }

                it 'returns Refute::Raw' do
                  expect(ruling.refute).to be_a(Refute::Raw)
                end
              end
            end

            describe '#dispute' do
              context 'with Invalidate' do
                let(:ruling) { Ruling::Invalidate(error) }

                it 'returns Dispute' do
                  expect(ruling.dispute).to be_a(Dispute)
                end
              end

              context 'with Invalidate::Raw' do
                let(:ruling) { Ruling::Invalidate(:invalid) }

                it 'returns Dispute::Raw' do
                  expect(ruling.dispute).to be_a(Dispute::Raw)
                end
              end
            end

            describe '#structured_error' do
              let(:coordinator) { Adapters::Errors::Default }

              context 'with Dispute' do
                let(:ruling) { Ruling::Dispute(error) }

                it 'returns error' do
                  expect(ruling.structured_error(coordinator)).to be(error)
                end
              end

              context 'with Refute' do
                let(:ruling) { Ruling::Refute(error) }

                it 'returns error' do
                  expect(ruling.structured_error(coordinator)).to be(error)
                end
              end
            end
          end

          context 'with raw error data' do
            describe '#structured_error' do
              let(:coordinator) { Adapters::Errors::Default }

              context 'with Dispute' do
                let(:ruling) { Ruling::Dispute(:invalid, message: 'Invalid', data: 5) }

                it 'returns error' do
                  expect(ruling.structured_error(coordinator))
                    .to have_attributes(class: StructuredError::Record, code: :invalid, message: 'Invalid', data: 5)
                end
              end

              context 'with Refute' do
                let(:ruling) { Ruling::Refute(:invalid, message: 'Invalid', data: 5) }

                it 'returns error' do
                  expect(ruling.structured_error(coordinator))
                    .to have_attributes(class: StructuredError::Record, code: :invalid, message: 'Invalid', data: 5)
                end
              end
            end
          end
        end
      end
    end
  end
end
