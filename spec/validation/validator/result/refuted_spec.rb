# frozen_string_literal: true

require_relative '../support/unit/result'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Result
        RSpec.describe Refuted do
          let(:initial_error) { StructuredError::Record.instance(:err, message: 'Error 1') }
          let(:later_error) { StructuredError::Record.instance(:err, message: 'Error 2') }
          let(:refuted) { described_class.instance(initial_error) }

          it 'is failure' do
            expect(refuted).to be_failure
          end

          describe '#to_result' do
            it 'returns the refutation' do
              expect(refuted.to_result(Support::Unit::Coordinators::Dry::Flat).failure)
                .to contain_exactly(['', [StructuredError::Record.instance(:err, message: 'Error 1')]])
            end
          end

          describe '#commit' do
            it 'returns self' do
              expect(refuted.commit(5)).to be(refuted)
            end
          end

          describe '#dispute' do
            it 'returns self' do
              expect(refuted.dispute(later_error)).to be(refuted)
            end
          end

          describe '#refute' do
            it 'returns self' do
              expect(refuted.refute(later_error)).to be(refuted)
            end
          end

          describe '#navigate' do
            it 'returns self' do
              expect(refuted.navigate(:foo) {}).to be(refuted)
            end
          end
        end
      end
    end
  end
end
