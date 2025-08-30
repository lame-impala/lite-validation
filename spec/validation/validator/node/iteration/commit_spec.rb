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

          context 'when committing the collection' do
            context 'when value has been updated in the first iteration' do
              let(:value) { { foo: [{ val: 5 }, { val: 6 }] } }
              let(:result) do
                valid.each_at(:foo) do |node|
                  node.validate(:val) { Commit(_1 + 1) }
                end.each_at(:foo, commit: target) do |node, _ctx|
                  node.commit("val: #{node.result.children[:val].value}")
                end.auto_commit(as: :hash)
              end

              context 'with array as the target collection' do
                let(:target) { :array }

                it 'commits the collection as hash' do
                  expect(result.to_result.success[:foo])
                    .to eq(['val: 6', 'val: 7'])
                end
              end

              context 'with hash as the target collection' do
                let(:target) { :hash }

                it 'commits the collection as hash' do
                  expect(result.to_result.success[:foo])
                    .to eq({ 0 => 'val: 6', 1 => 'val: 7' })
                end
              end
            end

            context 'with manual commit' do
              let(:result) do
                valid.each_at(:foo, commit: target)
                     .validate do |value, _ctx|
                  Commit(value + 1)
                end.auto_commit(as: :hash)
              end
              let(:value) { { foo: [0, 50, 100] } }

              context 'with array as the target collection' do
                let(:target) { :array }

                it 'commits the collection as array' do
                  expect(result.to_result.success[:foo]).to eq([1, 51, 101])
                end
              end

              context 'with hash as the target collection' do
                let(:target) { :hash }

                it 'commits the collection as hash' do
                  expect(result.to_result.success[:foo])
                    .to eq({ 0 => 1, 1 => 51, 2 => 101 })
                end
              end
            end

            context 'with commit parameter to the validator' do
              let(:result) do
                valid.each_at(:foo, commit: target)
                     .validate(commit: true) do |_value, _ctx|
                  Pass()
                end.auto_commit(as: :hash)
              end
              let(:value) { { foo: [0, 50, 100] } }

              context 'with array as the target collection' do
                let(:target) { :array }

                it 'commits the collection as array' do
                  expect(result.to_result.success[:foo]).to eq([0, 50, 100])
                end
              end

              context 'with hash as the target collection' do
                let(:target) { :hash }

                it 'commits the collection as hash' do
                  expect(result.to_result.success[:foo])
                    .to eq({ 0 => 0, 1 => 50, 2 => 100 })
                end
              end
            end
          end
        end
      end
    end
  end
end
