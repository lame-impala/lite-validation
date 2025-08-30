# frozen_string_literal: true

require_relative '../support/unit/result'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Result
        RSpec.describe Committed do
          let(:committed) { Result.valid.commit(5) }
          let(:later_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }

          it 'is success' do
            expect(committed).to be_success
          end

          describe '#to_result' do
            it 'wraps value into success' do
              expect(committed.to_result(Support::Unit::Coordinators::Dry::Flat).success).to eq(Option.some(5))
            end
          end

          describe '#commit' do
            it 'raises error' do
              expect { committed.commit(5) }
                .to raise_error(Error, "Can't reopen committed result")
            end
          end

          describe '#dispute' do
            it 'raises error' do
              expect { committed.dispute(later_error) }
                .to raise_error(Error, "Can't reopen committed result")
            end
          end

          describe '#refute' do
            it 'raises error' do
              expect { committed.refute(later_error) }
                .to raise_error(Error, "Can't reopen committed result")
            end
          end

          describe '#navigate' do
            it 'raises error' do
              expect { committed.navigate(:foo) {} }
                .to raise_error(Error, "Can't reopen committed result")
            end
          end
        end
      end
    end
  end
end
