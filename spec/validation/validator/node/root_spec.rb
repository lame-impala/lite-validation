# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      class TestObject
        def initialize(id, data)
          @id = id
          @data = data
        end

        attr_reader :id, :data
      end

      RSpec.describe Node::Root do
        include Ruling::Constructors

        let(:root) do
          Validator.instance(
            value,
            Support::Unit::Coordinators::Dry::Hierarchical,
            context: { foo: 'BAR' }
          )
        end
        let(:valid) { root }

        describe '#at' do
          context 'with object value' do
            let(:value) { TestObject.new(15, { name: 'John Doe' }) }

            context 'when navigating to valid attribute' do
              it 'yields child' do
                expect do |yield_probe|
                  root.at(:data, :name) do |node|
                    yield_probe.to_proc.call(node)
                    expect(node.value).to eq('John Doe')
                    node
                  end
                end.to yield_control
              end
            end

            context 'when navigating to invalid attribute' do
              it 'refutes the node' do
                expect(root.at(:name).to_result.failure)
                  .to match({ children: { name: { errors: [have_attributes(code: :invalid_access)] } } })
              end
            end
          end

          context 'with hash value' do
            let(:value) { { a: { b: 'B' } } }

            context 'with empty path' do
              it 'yields root/leaf' do
                expect do |yield_probe|
                  root.at do |node|
                    yield_probe.to_proc.call(node)
                    expect(node).to be_a(Node::Root::Leaf)
                    node
                  end
                end.to yield_control
              end

              it 'returns root/leaf' do
                expect(root.at { _1 }).to be_a(Node::Root::Leaf)
              end
            end

            context 'with non-empty path' do
              it 'yields child/leaf' do
                expect do |yield_probe|
                  root.at(:a) do |node|
                    yield_probe.to_proc.call(node)
                    expect(node).to be_a(Node::Child::Leaf)
                    node
                  end
                end.to yield_control
              end

              it 'returns root/branch' do
                expect(root.at(:a) { _1 }).to be_a(Node::Root::Branch)
              end
            end
          end
        end
      end
    end
  end
end
