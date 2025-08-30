# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared/contexts/fake_validator'
require_relative '../../support/unit/coordinators/dry'
require_relative '../../support/shared/predicates/dry'

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

          describe 'each_at' do
            context 'when called without block' do
              context 'when followed by #validate' do
                let(:result) do
                  valid.each_at(:foo).validate do |value, _ctx|
                    next Refute(:blank) if value.nil?

                    Dispute(:negative) if value < 0
                  end
                end
                let(:value) { { foo: [5, -1, nil, 6] } }

                let(:expected_errors) do
                  {
                    1 => { errors: [have_attributes(code: :negative)] },
                    2 => { errors: [have_attributes(code: :blank)] }
                  }
                end

                it 'runs validation on each element' do
                  expect(result.to_result.failure.dig(:children, :foo, :children))
                    .to match(expected_errors)
                end
              end

              context 'when followed by #satisfy' do
                let(:result) do
                  valid.each_at(:foo)
                       .satisfy(using: :dry, severity: :dispute, commit: true) do |builder, context|
                    builder.call { gteq?(0) & lteq?(context[:max]) }
                  end
                end
                let(:value) { { foo: [0, -1, 100, 101] } }
                let(:context) { { max: 100 } }

                let(:expected_errors) do
                  {
                    1 => { errors: [have_attributes(code: :'failed: gteq?(0) AND lteq?(100)')] },
                    3 => { errors: [have_attributes(code: :'failed: gteq?(0) AND lteq?(100)')] }
                  }
                end

                it 'tests predicate on each element' do
                  expect(result.to_result.failure.dig(:children, :foo, :children))
                    .to match(expected_errors)
                end
              end
            end
          end
        end
      end
    end
  end
end
