# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'
require_relative '../support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Predication do
          include Ruling::Constructors

          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: { foo: 'BAR' }
            )
          end
          let(:value) { { foo: 'FOO', bar: nil } }

          let(:valid) { root }
          let(:refuted) { root.refute(first_error) }

          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }

          describe '#satisfy?' do
            context 'when predicate is satisfied' do
              it 'returns valid result' do
                expect(valid.satisfy?(:foo) { :presence }.to_result).to be_success
              end
            end

            context 'when predicate is not satisfied' do
              it 'returns disputed result' do
                result = valid.satisfy?(:bar) { :presence }
                expect(result.to_result.failure.dig(:children, :bar, :errors).map(&:code))
                  .to contain_exactly(:blank)
              end
            end

            context 'when value is missing' do
              it 'returns valid result' do
                result = valid.satisfy?(:bax) { :presence }
                expect(result.to_result).to be_success
              end
            end

            context 'when suspended as option' do
              context 'when value is present and definite' do
                it 'returns valid result' do
                  expect(valid.satisfy?(:foo).option { :presence }.to_result).to be_success
                end
              end

              context 'when value is present and nil' do
                it 'returns disputed result' do
                  expect(valid.satisfy?(:bar).option { :presence }.to_result).to be_failure
                end
              end

              context 'when value is missing' do
                it 'returns disputed result' do
                  expect(valid.satisfy?(:bax).option { :presence }.to_result).to be_failure
                end
              end
            end
          end

          describe '#satisfy' do
            context 'when value is present' do
              context 'when predicate is satisfied' do
                it 'returns valid result' do
                  expect(valid.satisfy(:foo) { :presence }.to_result).to be_success
                end

                context 'with commit as true' do
                  it 'commits the result' do
                    expect(valid.satisfy(:foo, commit: true) { :presence }.auto_commit(as: :hash).to_result.success)
                      .to eq({ foo: 'FOO' })
                  end
                end
              end

              context 'when predicate is not satisfied' do
                it 'returns disputed result' do
                  result = valid.satisfy(:bar) { :presence }
                  expect(result.to_result.failure.dig(:children, :bar, :errors).map(&:code))
                    .to contain_exactly(:blank)
                end
              end

              context 'when value is missing' do
                it 'returns disputed result' do
                  result = valid.satisfy(:bax) { :presence }
                  expect(result.to_result.failure.dig(:children, :bax, :errors).map(&:code))
                    .to contain_exactly(:value_missing)
                end
              end
            end
          end
        end
      end
    end
  end
end
