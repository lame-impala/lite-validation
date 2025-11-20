# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Transformation do
          subject(:result) { validator.auto_commit(as: :hash).to_result }

          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: { foo: 'BAR' }
            )
          end
          let(:valid) { root }
          let(:committed) { root.commit(2) }
          let(:disputed) { root.dispute(first_error) }
          let(:refuted) { root.refute(first_error) }

          let(:value) { { foo: 'FOO', bar: { a: 'A', b: 'B' } } }
          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }

          describe '#transform' do
            context 'when result is committed' do
              it 'raises error' do
                expect { committed.transform(:foo) { _1 } }
                  .to raise_error(Error, "Can't reopen committed result")
              end
            end

            context 'when result is refuted' do
              it "doesn't yield into the block" do
                expect do |yield_probe|
                  refuted.transform(:foo, &yield_probe)
                end.not_to yield_control
              end
            end

            context 'when result is disputed' do
              it "doesn't yield into the block" do
                expect do |yield_probe|
                  disputed.transform(:foo, &yield_probe)
                end.not_to yield_control
              end
            end

            context 'with empty path' do
              let(:result) { valid.transform(from: [:foo]) { _1.downcase }.to_result }

              it 'commits the value at root level' do
                expect(result.value!).to eq('foo')
              end
            end

            context 'when all values are present' do
              let(:validator) do
                valid.transform(:foo) { _1.downcase }
                     .transform(:bar_a, from: %i[bar a]) { _1.downcase }
                     .transform(:bar_b, from: %i[bar b]) { _1.downcase }
              end

              it 'commits transformed values at given keys' do
                expect(result.value!).to eq({ foo: 'foo', bar_a: 'a', bar_b: 'b' })
              end
            end

            context 'when some values are missing' do
              let(:validator) do
                valid.transform(:foo) { _1.downcase }
                     .transform(:bar_x, from: %i[bar x]) { _1.downcase }
              end

              it 'returns disputed validator' do
                expect(result.failure)
                  .to match(children: { bar_x: { errors: [have_attributes(code: :value_missing)] } })
              end
            end

            context 'when transformation block raises' do
              let(:validator) do
                valid.transform(:foo) { raise 'Error!' }
              end

              it 'returns disputed validator' do
                expect(result.failure)
                  .to match(children: { foo: { errors: [have_attributes(code: :execution_error)] } })
              end

              context 'when committing to a deeper node' do
                let(:validator) do
                  valid.transform(:foo) { _1.downcase }
                       .transform(:bar, :a, from: %i[bar a]) { _1.downcase }
                       .transform(:bar, :b, from: %i[bar b]) { _1.downcase }
                       .at(:bar) { _1.auto_commit(as: :hash) }
                end

                it 'commits transformed values at given keys' do
                  expect(result.value!).to eq({ foo: 'foo', bar: { a: 'a', b: 'b' } })
                end
              end

              context 'when committing a tuple' do
                let(:validator) do
                  valid.transform(:tuple, from: [[:foo, %i[bar a]]]) { _1.join('-').downcase }
                end

                it 'commits transformed tuple' do
                  expect(result.value!).to eq(tuple: 'foo-a')
                end
              end
            end
          end

          describe '#transform?' do
            context 'with immediate block' do
              context 'when value is present' do
                let(:validator) { valid.transform?(:foo) { _1.downcase } }

                it 'commits the transformed value' do
                  expect(result.value!).to eq(foo: 'foo')
                end
              end

              context 'when value is missing' do
                let(:validator) do
                  valid.transform?(:bax) { _1.downcase }
                       .transform(:foo) { _1.downcase }
                end

                it 'skips the transformation block' do
                  expect(result.value!).to eq(foo: 'foo')
                end
              end
            end

            context 'when suspended as option' do
              let(:validator) do
                valid.transform?(:foo).option { _1.value!.downcase }
                     .transform?(:bax).option { _1.value_or { 'BAX' }.downcase }
              end

              it 'yields option to the block and commits the transformed value' do
                expect(result.value!).to eq(foo: 'foo', bax: 'bax')
              end
            end

            context 'when suspended as some_or_nil' do
              let(:validator) do
                valid.transform?(:foo).some_or_nil { _1&.downcase || 'N/A' }
                     .transform?(:bax).some_or_nil { _1&.downcase || 'N/A' }
              end

              it 'yields nil for missing value and commits the transformed value' do
                expect(result.value!).to eq(foo: 'foo', bax: 'N/A')
              end
            end
          end
        end
      end
    end
  end
end
