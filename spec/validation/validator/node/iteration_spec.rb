# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/shared/contexts/fake_validator'
require_relative '../support/unit/coordinators/dry'
require_relative '../support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Iteration do
          include Ruling::Constructors

          let(:valid) { root }
          let(:refuted) { root.refute(first_error) }
          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: context
            )
          end
          let(:context) { { foo: 'BAR' } }

          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
          let(:second_error) { StructuredError::Record.instance(:err1, message: 'Error 2') }

          describe '#each_at?' do
            context 'when value is missing' do
              let(:value) { { foo: 5 } }

              it "doesn't yield to the block" do
                expect do |yield_probe|
                  result = valid.each_at?(:array, &yield_probe)
                  expect(result.to_result).to be_success
                end.not_to yield_control
              end
            end

            context 'when value is not iterable' do
              let(:value) { { foo: 5 } }

              it 'refutes the key as non-iterable' do
                result = valid.each_at?(:foo) {}

                expect(result.to_result.failure)
                  .to match({ children: { foo: { errors: [have_attributes(code: :not_iterable)] } } })
              end
            end

            context 'with array value' do
              let(:value) { { array: %w[FOO BAR] } }

              context 'with refuted result' do
                it "doesn't yield to the block" do
                  expect do |yield_probe|
                    refuted.each_at?(:array, &yield_probe)
                  end.not_to yield_control
                end
              end

              context 'with valid result' do
                it 'yields subsequent element validators into the block' do
                  result = valid.each_at?(:array) do |node|
                    node.commit("#{node.key}:#{node.value}")
                  end.at?(:array) { _1.auto_commit(as: :array) }.auto_commit(as: :hash)
                  expect(result.to_result.success).to eq({ array: %w[0:FOO 1:BAR] })
                end
              end

              context 'when context is updated' do
                it 'yields subsequent nodes into the block with updated context' do
                  result = valid.each_at?(:array) do |node|
                    node.commit("#{node.context[:previous]}->#{node.key}:#{node.value}")
                        .with_context(node.context.merge(previous: node.value))
                  end.at?(:array) { _1.auto_commit(as: :array) }.auto_commit(as: :hash)

                  expect(result.to_result.success).to eq({ array: %w[->0:FOO FOO->1:BAR] })
                end
              end
            end

            context 'with hash value' do
              let(:value) { { hash: { foo: 'FOO', bar: 'BAR' } } }

              context 'with valid result' do
                it 'yields subsequent element validators into the block' do
                  result = valid.each_at?(:hash) do |node|
                    node.commit("#{node.key}:#{node.value}")
                  end.at?(:hash) { _1.auto_commit(as: :hash) }.auto_commit(as: :hash)
                  expect(result.to_result.success).to eq({ hash: { foo: 'foo:FOO', bar: 'bar:BAR' } })
                end
              end
            end
          end

          describe '#each_at' do
            context 'when value is missing' do
              let(:value) { { foo: 5 } }

              it 'refutes the missing key' do
                result = valid.each_at(:array) {}

                expect(result.to_result.failure)
                  .to match({ children: { array: { errors: [have_attributes(code: :value_missing)] } } })
              end
            end

            context 'when value is not iterable' do
              let(:value) { { foo: 5 } }

              it 'refutes the key' do
                result = valid.each_at(:foo) {}

                expect(result.to_result.failure)
                  .to match({ children: { foo: { errors: [have_attributes(code: :not_iterable)] } } })
              end
            end

            context 'when node with non-matching origin is returned' do
              include_context 'with fake validator'

              let(:value) { { foo: [5, 6] } }

              context 'with valid result' do
                it 'raises error' do
                  expect do
                    valid.each_at(:foo) { fake }
                  end.to raise_error(Error, /Not the intent: \[\d+,foo,0\] <> \[\d+\]/)
                end
              end
            end
          end
        end
      end
    end
  end
end
