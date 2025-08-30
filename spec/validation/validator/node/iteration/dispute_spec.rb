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
          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical
            )
          end

          context 'when the collection has been previously visited' do
            context 'when simple value has been disputed in the first iteration' do
              let(:value) { { foo: [5, 6] } }
              let(:result) do
                valid.each_at(:foo).validate do |_value, _ctx|
                  Dispute(:first_error)
                end.each_at(:foo, commit: :hash).validate do |_value, _ctx|
                  Dispute(:second_error)
                end.auto_commit(as: :hash)
              end

              it 'stores errors from both iterations' do
                actual_errors = result
                                .to_result
                                .failure
                                .dig(:children, :foo, :children)
                                .transform_values { _1[:errors].map(&:code) }

                expect(actual_errors)
                  .to eq({ 0 => %i[first_error second_error], 1 => %i[first_error second_error] })
              end
            end

            context 'when complex value has been disputed in the first iteration' do
              let(:value) { { foo: [{ val: 5, name: 'foo1' }, { val: 6, name: 'foo2' }] } }
              let(:result) do
                valid.each_at(:foo) do |node|
                  node.validate(:val) { Dispute(:first_error) }
                end.each_at(:foo) do |node|
                  node.validate(:name) { Dispute(:second_error) }
                end
              end

              it 'stores errors from both iterations' do
                actual_errors = result
                                .to_result
                                .failure
                                .dig(:children, :foo, :children)
                                .transform_values { _1.dig(:children) }
                                .transform_values { [_1.dig(:val, :errors), _1.dig(:name, :errors)] }
                                .transform_values { |(val, name)| val.map(&:code) + name.map(&:code) }

                expect(actual_errors)
                  .to eq({ 0 => %i[first_error second_error], 1 => %i[first_error second_error] })
              end
            end
          end
        end
      end
    end
  end
end
