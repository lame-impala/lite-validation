# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../lib/lite/validation/validator'
require_relative '../../support/unit/coordinators/dry'
require_relative '../../support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          RSpec.describe 'Dry' do
            context 'with single value' do
              let(:predicate) do
                Registry.engine(:dry).build_contextual([[:foo]], context) do |dry, context|
                  dry.call { gteq?(context[:min]) & lt?(context[:max]) }
                end
              end
              let(:context) { { min: 0, max: 5 } }

              context 'when rule passes' do
                it 'returns Pass' do
                  expect(predicate.definite.call(1, context))
                    .to eq(Ruling::Pass())
                end
              end

              context 'when rule fails' do
                it 'returns Dispute with well formed error' do
                  expect(predicate.definite.call(5, context).error)
                    .to eq(StructuredError::Record.instance(:'failed: gteq?(0) AND lt?(5)', data: 5))
                end
              end
            end

            context 'with tuple' do
              let(:predicate) do
                Registry.engine(:dry).build([[:foo], [:bar]]) do |dry, _context|
                  dry.call { lt? }
                end
              end

              context 'when rule passes' do
                it 'returns Pass' do
                  expect(predicate.definite.call([2, 1], nil))
                    .to eq(Ruling::Pass())
                end
              end

              context 'when rule fails' do
                context 'with severity as disputed' do
                  it 'returns disputed ruling with well formed error' do
                    expect(predicate.dispute.definite.call([1, 2], nil))
                      .to eq(Ruling::Dispute(StructuredError::Record.instance(:'failed: lt?', data: [1, 2])))
                  end
                end

                context 'with severity as refuted' do
                  it 'returns refuted ruling with well formed error' do
                    expect(predicate.refute.definite.call([1, 2], nil))
                      .to eq(Ruling::Refute(StructuredError::Record.instance(:'failed: lt?', data: [1, 2])))
                  end
                end
              end
            end

            describe 'validator integration' do
              Registry.register_predicate(:dry_lt, Registry.engine(:dry).build(%i[rhs lhs]) { lt? })

              subject(:result) do
                Validator.instance(data, Support::Unit::Coordinators::Dry::Flat, context: { min: 0, max: 5 }).at do |node|
                  node.satisfy(:foo, using: :dry, severity: :refute) do |builder, context|
                    builder.call { gteq?(context[:min]) & lt?(context[:max]) }
                  end.satisfy(%i[foo bar], severity: :refute) { :dry_lt }
                end.to_result
              end

              context 'with valid data' do
                let(:data) { { foo: 3, bar: 2 } }

                it 'returns success' do
                  expect(result).to be_success
                end
              end

              context 'with invalid data' do
                let(:data) { { foo: 5, bar: 6 } }

                let(:expected_errors) do
                  [
                    ['foo', [StructuredError::Record.instance('failed: gteq?(0) AND lt?(5)', data: 5)]],
                    ['(foo,bar)', [StructuredError::Record.instance('failed: lt?', data: [5, 6])]]
                  ]
                end

                it 'builds correct error code' do
                  expect(result.failure).to match_array(expected_errors)
                end
              end
            end
          end
        end
      end
    end
  end
end
