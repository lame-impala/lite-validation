# frozen_string_literal: true

require_relative '../support/unit/result'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Result
        RSpec.describe Valid do
          let(:valid) { Result.valid }
          let(:later_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }

          it 'is success' do
            expect(valid).to be_success
          end

          describe '#to_result' do
            it 'returns none' do
              expect(valid.to_result(Support::Unit::Coordinators::Dry::Flat).success)
                .to be(Option.none)
            end
          end

          describe '#commit' do
            it 'returns committed validator' do
              expect(valid.commit(5)).to be_a(Committed)
            end
          end

          describe '#dispute' do
            it 'returns disputed validation' do
              expect(valid.dispute(later_error)).to be_a(Disputed::Navigable)
            end
          end

          describe '#refute' do
            it 'returns refuted validation' do
              expect(valid.refute(later_error)).to be_a(Refuted)
            end
          end

          describe '#navigate' do
            context 'when child returns as valid' do
              it 'calls into block and returns self' do
                expect do |yield_probe|
                  updated, _meta = valid.navigate(:foo) do |result|
                    yield_probe.to_proc.call
                    result
                  end
                  expect(updated).to be(valid)
                end.to yield_control
              end
            end

            context 'when child returns as committed' do
              let(:result) do
                updated, _meta = valid.navigate(:foo) do |result|
                  result.commit(5)
                end
                updated
              end

              it 'calls into block and returns valid' do
                expect(result).to be_a(Valid::Navigable)
              end

              it 'stores the committed child' do
                expect(result.auto_commit(as: :hash).to_result(Support::Unit::Coordinators::Dry::Flat).success)
                  .to eq(Option.some(foo: 5))
              end
            end

            context 'when child returns as disputed' do
              it 'calls into block and returns disputed' do
                updated, _meta = valid.navigate(:foo) do |result|
                  result.dispute(later_error)
                end

                expect(updated.to_result(Support::Unit::Coordinators::Dry::Flat).failure)
                  .to contain_exactly(['foo', [later_error]])
              end
            end

            context 'when child returns as rejected' do
              it 'calls into block and returns disputed' do
                updated, _meta = valid.navigate(:foo) do |result|
                  result.refute(later_error)
                end

                expect(updated.to_result(Support::Unit::Coordinators::Dry::Flat).failure)
                  .to contain_exactly(['foo', [later_error]])
              end
            end

            context 'when refuted result is returned with fall through flag' do
              it 'unwraps the result at root' do
                result, _meta = valid.navigate(:foo) { valid.refute(later_error).with(fall_through: true) }
                expect(result).to be_refuted
              end
            end
          end
        end
      end
    end
  end
end
