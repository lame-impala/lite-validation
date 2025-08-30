# frozen_string_literal: true

require_relative '../support/unit/result'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Result
        RSpec.describe Committed do
          let(:disputed) { Result.valid.dispute(initial_error) }
          let(:initial_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
          let(:later_error) { StructuredError::Record.instance(:err2, message: 'Error 2') }

          context 'with errors' do
            it 'is failure' do
              expect(disputed).to be_failure
            end

            describe '#to_result' do
              it 'returns the error' do
                expect(disputed.to_result(Support::Unit::Coordinators::Dry::Flat).failure)
                  .to contain_exactly(['', [initial_error]])
              end
            end

            describe '#dispute' do
              it 'appends error' do
                updated = disputed.dispute(StructuredError::Record.instance(:err2, message: 'Error 2'))
                errors = updated
                         .to_result(Support::Unit::Coordinators::Dry::Flat)
                         .failure
                         .map { |key, errors| [key, errors.map(&:code)] }

                expect(errors)
                  .to contain_exactly(['', %i[err1 err2]])
              end
            end

            describe '#refute' do
              it 'returns refuted result' do
                refuted = disputed.refute(StructuredError::Record.instance(:err2, message: 'Error 2'))
                expect(refuted).to be_a(Refuted)
              end
            end

            describe '#commit' do
              it 'returns self' do
                expect(disputed.commit(5)).to eq(disputed)
              end
            end

            describe '#navigate' do
              context 'when child returns as valid' do
                it 'calls into block and returns self' do
                  expect do |yield_probe|
                    updated, _meta = disputed.navigate(:foo) do |result|
                      yield_probe.to_proc.call
                      result
                    end
                    expect(updated).to be(disputed)
                  end.to yield_control
                end
              end

              context 'when child returns as committed' do
                let(:result) do
                end

                it 'calls into block and returns self' do
                  expect do |yield_probe|
                    updated, _meta = disputed.navigate(:foo) do |result|
                      yield_probe.to_proc.call
                      result
                    end
                    expect(updated).to be(disputed)
                  end.to yield_control
                end
              end

              context 'when child returns as disputed' do
                it 'calls into block and returns disputed' do
                  updated, _meta = disputed.navigate(:foo) do |result|
                    result.dispute(later_error)
                  end

                  expect(updated.to_result(Support::Unit::Coordinators::Dry::Flat).failure)
                    .to contain_exactly(['', [initial_error]], ['foo', [later_error]])
                end
              end

              context 'when child returns as rejected' do
                it 'calls into block and returns disputed' do
                  updated, _meta = disputed.navigate(:foo) do |result|
                    result.refute(later_error)
                  end

                  expect(updated.to_result(Support::Unit::Coordinators::Dry::Flat).failure)
                    .to contain_exactly(['', [initial_error]], ['foo', [later_error]])
                end
              end
            end
          end
        end
      end
    end
  end
end
