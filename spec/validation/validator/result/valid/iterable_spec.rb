# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/test_reducer'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          RSpec.describe Iterable do
            let(:result) do
              Node::TestReducer.reduce(iterable, data, block)
            end
            let(:data) { [5, -1, 6] }
            let(:block) do
              lambda { |_iterable, _key, value, result, _context|
                case value
                when -1
                  result.navigate(:meta) { _1.commit('META') }
                when -2
                  result.dispute(StructuredError::Record.instance(:invalid))
                else
                  [result.commit(value + 1), nil]
                end
              }
            end

            describe Iterable::Array::Tuples do
              context 'when uncommitted' do
                let(:iterable) { described_class.instance(false) }
                let(:expected_children) do
                  [
                    [0, have_attributes(value: 6)],
                    [1, have_attributes(committed?: false)],
                    [2, have_attributes(value: 7)]
                  ]
                end

                it 'stores children in an array of tuples' do
                  expect(result.children)
                    .to match(expected_children)
                end

                context 'when a node is disputed' do
                  let(:data) { [5, -2, 6] }

                  let(:expected_children) do
                    [[1, have_attributes(class: Result::Disputed::Navigable)]]
                  end

                  it 'returns disputed node' do
                    expect(result).to be_a(Result::Disputed::Iterable::Array)
                  end

                  it 'returns node with disputed children' do
                    expect(result.children)
                      .to match(expected_children)
                  end
                end

                describe '#navigable' do
                  let(:expected_children) do
                    {
                      0 => have_attributes(value: 6),
                      1 => have_attributes(committed?: false),
                      2 => have_attributes(value: 7)
                    }
                  end

                  it 'returns node with committed children' do
                    expect(result.navigable.children)
                      .to match(expected_children)
                  end
                end
              end

              context 'when committed as hash' do
                let(:iterable) { described_class.instance(:hash) }
                let(:expected_children) do
                  [
                    [0, 6],
                    [2, 7]
                  ]
                end

                it 'stores children in an array of tuples' do
                  expect(result.children)
                    .to match(expected_children)
                end

                describe '#navigable' do
                  it 'returns committed node' do
                    expect(result.navigable.value)
                      .to eq({ 0 => 6, 2 => 7 })
                  end
                end
              end
            end

            describe Iterable::Array::Values do
              let(:iterable) { described_class.instance }
              let(:expected_children) { [6, 7] }

              it 'stores children in an array of values' do
                expect(result.children)
                  .to match(expected_children)
              end

              context 'when a node is disputed' do
                let(:data) { [5, -2, 6] }

                let(:expected_children) do
                  [[1, have_attributes(class: Result::Disputed::Navigable)]]
                end

                it 'returns disputed node' do
                  expect(result).to be_a(Result::Disputed::Iterable::Array)
                end

                it 'returns node with disputed children' do
                  expect(result.children)
                    .to match(expected_children)
                end
              end

              describe '#navigable' do
                it 'returns committed node' do
                  expect(result.navigable.value)
                    .to eq([6, 7])
                end
              end
            end

            describe Iterable::Hash do
              let(:iterable) { described_class.instance(:hash, {}) }
              let(:expected_children) do
                {
                  0 => have_attributes(value: 6),
                  2 => have_attributes(value: 7)
                }
              end

              it 'stores errors in a hash' do
                expect(result.children)
                  .to match(expected_children)
              end

              context 'when a node is disputed' do
                let(:data) { [5, -2, 6] }

                let(:expected_children) do
                  [[1, have_attributes(class: Result::Disputed::Navigable)]]
                end

                it 'returns disputed node' do
                  expect(result).to be_a(Result::Disputed::Iterable::Array)
                end

                it 'returns node with disputed children' do
                  expect(result.children)
                    .to match(expected_children)
                end
              end

              describe '#navigable' do
                it 'returns committed node' do
                  expect(result.navigable.value)
                    .to eq({ 0 => 6, 2 => 7 })
                end
              end
            end
          end
        end
      end
    end
  end
end
