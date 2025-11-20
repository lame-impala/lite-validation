# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::ApplyRuling do
          include Ruling::Constructors

          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: { foo: 'BAR' }
            )
          end
          let(:value) { 5 }
          let(:valid) { root }
          let(:committed) { root.commit(2) }
          let(:disputed) { root.dispute(first_error) }
          let(:refuted) { root.refute(first_error) }

          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
          let(:second_error) { StructuredError::Record.instance(:err1, message: 'Error 2') }

          describe '#commit' do
            context 'when result is valid' do
              it 'returns committed validator' do
                expect(valid.commit(2).result)
                  .to have_attributes(class: Result::Committed, success: Option.some(2))
              end

              context 'when nested key is committed' do
                let(:committed) do
                  valid.commit('FOO', at: :foo)
                       .commit('BAR', at: :bar)
                       .auto_commit(as: :hash)
                       .to_result
                       .value!
                end

                it 'commits child at given path' do
                  expect(committed)
                    .to eq({ foo: 'FOO', bar: 'BAR' })
                end
              end
            end

            context 'when result is committed' do
              it 'raises error' do
                expect { committed.commit(2) }
                  .to raise_error(Error, "Can't reopen committed result")
              end
            end

            context 'when result is disputed' do
              it 'returns disputed validator' do
                expect(disputed.commit(2).result)
                  .to have_attributes(class: Result::Disputed::Navigable, errors_root: [first_error])
              end
            end

            context 'when result is refuted' do
              it 'returns refuted validator' do
                expect(refuted.commit(2).result)
                  .to have_attributes(class: Result::Refuted, errors_root: [first_error])
              end
            end
          end

          describe '#dispute' do
            context 'when result is valid' do
              it 'returns disputed validator' do
                expect(valid.dispute(first_error).result)
                  .to have_attributes(class: Result::Disputed::Navigable, errors_root: [first_error])
              end
            end

            context 'when result is committed' do
              it 'raises error' do
                expect { committed.commit(2) }
                  .to raise_error(Error, "Can't reopen committed result")
              end
            end

            context 'when result is disputed' do
              it 'returns disputed validator' do
                expect(disputed.dispute(second_error).result)
                  .to have_attributes(class: Result::Disputed::Navigable, errors_root: [first_error, second_error])
              end
            end

            context 'when result is refuted' do
              it 'returns refuted validator' do
                expect(refuted.dispute(second_error).result)
                  .to have_attributes(class: Result::Refuted, errors_root: [first_error])
              end
            end

            context 'when nested key is disputed' do
              it 'disputes child at given path' do
                expect(disputed.dispute(second_error, at: :foo).to_result.failure)
                  .to match({ errors: [first_error], children: { foo: { errors: [second_error] } } })
              end
            end
          end

          describe '#refute' do
            context 'when result is valid' do
              it 'returns refuted validator' do
                expect(valid.refute(first_error).result)
                  .to have_attributes(class: Result::Refuted, errors_root: [first_error])
              end
            end

            context 'when result is committed' do
              it 'raises error' do
                expect { committed.commit(2) }
                  .to raise_error(Error, "Can't reopen committed result")
              end
            end

            context 'when result is disputed' do
              it 'returns refuted validator' do
                expect(disputed.refute(second_error).result)
                  .to have_attributes(class: Result::Refuted, errors_root: [second_error])
              end
            end

            context 'when result is refuted' do
              it 'returns refuted validator' do
                expect(refuted.refute(second_error).result)
                  .to have_attributes(class: Result::Refuted, errors_root: [first_error])
              end
            end

            context 'when nested key is refuted' do
              it 'refutes child at given path' do
                expect(disputed.refute(second_error, at: :foo).to_result.failure)
                  .to match({ errors: [first_error], children: { foo: { errors: [second_error] } } })
              end
            end
          end
        end
      end
    end
  end
end
