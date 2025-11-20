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

          describe '#commit_at' do
            context 'when result is committed' do
              it 'raises error' do
                expect { committed.commit_at(:foo) { _1 } }
                  .to raise_error(Error, "Can't reopen committed result")
              end
            end

            context 'when result is refuted' do
              it "doesn't yield into the block" do
                expect do |yield_probe|
                  refuted.commit_at(:foo, &yield_probe)
                end.not_to yield_control
              end
            end

            context 'when result is disputed' do
              it "doesn't yield into the block" do
                expect do |yield_probe|
                  disputed.commit_at(:foo, &yield_probe)
                end.not_to yield_control
              end
            end

            context 'with empty path' do
              let(:result) { valid.commit_at(from: [:foo]) { _1.downcase }.to_result }

              it 'commits the value at root level' do
                expect(result.value!).to eq('foo')
              end
            end

            context 'when all values are present' do
              let(:validator) do
                valid.commit_at(:foo) { _1.downcase }
                     .commit_at(:bar_a, from: %i[bar a]) { _1.downcase }
                     .commit_at(:bar_b, from: %i[bar b]) { _1.downcase }
              end

              it 'commits transformed values at given keys' do
                expect(result.value!).to eq({ foo: 'foo', bar_a: 'a', bar_b: 'b' })
              end
            end

            context 'when some values are missing' do
              let(:validator) do
                valid.commit_at(:foo) { _1.downcase }
                     .commit_at(:bar_x, from: %i[bar x]) { _1.downcase }
              end

              it 'returns disputed validator' do
                expect(result.failure)
                  .to match(children: { bar_x: { errors: [have_attributes(code: :value_missing)] } })
              end
            end

            context 'when transformation block raises' do
              let(:validator) do
                valid.commit_at(:foo) { raise 'Error!' }
              end

              it 'returns disputed validator' do
                expect(result.failure)
                  .to match(children: { foo: { errors: [have_attributes(code: :execution_error)] } })
              end

              context 'when committing to a deeper node' do
                let(:validator) do
                  valid.commit_at(:foo) { _1.downcase }
                       .commit_at(:bar, :a, from: %i[bar a]) { _1.downcase }
                       .commit_at(:bar, :b, from: %i[bar b]) { _1.downcase }
                       .at(:bar) { _1.auto_commit(as: :hash) }
                end

                it 'commits transformed values at given keys' do
                  expect(result.value!).to eq({ foo: 'foo', bar: { a: 'a', b: 'b' } })
                end
              end

              context 'when committing a tuple' do
                let(:validator) do
                  valid.commit_at(:tuple, from: [[:foo, %i[bar a]]]) { _1.join('-').downcase }
                end

                it 'commits transformed tuple' do
                  expect(result.value!).to eq(tuple: 'foo-a')
                end
              end
            end
          end

          describe '#commit_at?' do
            context 'with immediate block' do
              context 'when value is present' do
                let(:validator) { valid.commit_at?(:foo) { _1.downcase } }

                it 'commits the transformed value' do
                  expect(result.value!).to eq(foo: 'foo')
                end
              end

              context 'when value is missing' do
                let(:validator) do
                  valid.commit_at?(:bax) { _1.downcase }
                       .commit_at(:foo) { _1.downcase }
                end

                it 'skips the transformation block' do
                  expect(result.value!).to eq(foo: 'foo')
                end
              end
            end

            context 'when suspended as option' do
              let(:validator) do
                valid.commit_at?(:foo).option { _1.value!.downcase }
                     .commit_at?(:bax).option { _1.value_or { 'BAX' }.downcase }
              end

              it 'yields option to the block and commits the transformed value' do
                expect(result.value!).to eq(foo: 'foo', bax: 'bax')
              end
            end

            context 'when suspended as some_or_nil' do
              let(:validator) do
                valid.commit_at?(:foo).some_or_nil { _1&.downcase || 'N/A' }
                     .commit_at?(:bax).some_or_nil { _1&.downcase || 'N/A' }
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
