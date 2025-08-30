# frozen_string_literal: true

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Scoping do
          include Ruling::Constructors

          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: { foo: 'BAR' }
            )
          end
          let(:value) { 5 }
          let(:valid) { root }
          let(:committed) { root.commit(2) }
          let(:disputed) { root.dispute(first_error) }
          let(:refuted) { root.refute(first_error) }

          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
          let(:second_error) { StructuredError::Record.instance(:err1, message: 'Error 2') }

          describe '#with_context' do
            it 'yields validator with updated context to the block' do
              expect do |yield_probe|
                result = valid.with_context(bar: 'FOO') do |node|
                  yield_probe.to_proc.call
                  expect(node.context).to eq(bar: 'FOO')
                  node.dispute(first_error)
                end
                expect(result)
                  .to have_attributes(context: { foo: 'BAR' }, result: have_attributes(success?: false))
              end.to yield_control
            end
          end

          describe '#with_valid' do
            context 'with empty path' do
              context 'when result is valid' do
                it 'yields validator to the block' do
                  expect do |yield_probe|
                    result = valid.with_valid do |node|
                      yield_probe.to_proc.call
                      expect(node.result).to be_success
                      node.dispute(first_error)
                    end
                    expect(result.result)
                      .to have_attributes(class: Result::Disputed::Navigable, errors_root: [first_error])
                  end.to yield_control
                end
              end

              context 'when result is committed' do
                it 'yields validator to the block' do
                  expect do |yield_probe|
                    result = committed.with_valid do |node|
                      yield_probe.to_proc.call
                      expect(node.result).to be_success
                      node
                    end
                    expect(result).to be(committed)
                  end.to yield_control
                end
              end

              context 'when result is disputed' do
                it "doesn't yield to the block" do
                  expect do |yield_probe|
                    disputed.with_valid(&yield_probe)
                  end.not_to yield_control
                end
              end

              context 'when result is refuted' do
                it "doesn't yield to the block" do
                  expect do |yield_probe|
                    refuted.with_valid(&yield_probe)
                  end.not_to yield_control
                end
              end
            end

            context 'with non-empty path' do
              let(:value) { { bar: 'FOO' } }

              context 'when result is refuted' do
                it "doesn't yield to the block" do
                  expect do |yield_probe|
                    refuted.with_valid(:bar, &yield_probe)
                  end.not_to yield_control
                end
              end

              context 'when result at the path is valid' do
                it 'yields validator to the block' do
                  expect do |yield_probe|
                    disputed.with_valid(:bar) do |node|
                      yield_probe.to_proc.call
                      node
                    end
                  end.to yield_control
                end
              end

              context 'when result at the path is committed' do
                let(:with_committed_child) { valid.at(:bar) { _1.commit('foo') } }

                it 'yields validator to the block' do
                  expect do |yield_probe|
                    with_committed_child.with_valid(:bar) do |node|
                      yield_probe.to_proc.call
                      node
                    end
                  end.to yield_control
                end
              end

              context 'when result at the path is disputed' do
                let(:with_disputed_child) { valid.dispute(first_error, at: [:bar]) }

                it "doesn't yield validator to the block" do
                  expect do |yield_probe|
                    with_disputed_child.with_valid(:bar, &yield_probe)
                  end.not_to yield_control
                end
              end

              context 'when result at the path is refuted' do
                let(:with_refuted_child) { valid.refute(first_error, at: [:bar]) }

                it "doesn't yield validator to the block" do
                  expect do |yield_probe|
                    with_refuted_child.with_valid(:bar, &yield_probe)
                  end.not_to yield_control
                end
              end
            end
          end
        end
      end
    end
  end
end
