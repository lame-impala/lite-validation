# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/shared/contexts/fake_validator'
require_relative '../support/shared/contexts/critical_error_rewrap'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      RSpec.describe '#critical' do
        include_context 'with critical error rewrap'

        include Ruling::Constructors

        let(:root) do
          Validator.instance(
            value,
            Support::Unit::Coordinators::Dry::Hierarchical,
            context: { foo: 'BAR' }
          )
        end
        let(:valid) { root }
        let(:committed) { root.commit(5) }
        let(:refuted) { root.refute(later_error) }
        let(:later_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
        let(:value) { { foo: { bar: [1, 2] } } }

        context 'with disputable result' do
          it 'yields critical node to the block' do
            expect do |yield_probe|
              valid.critical(critical_error_rewrap) do |node|
                yield_probe.to_proc.call
                expect(node.merge_strategy).to be_a(State::MergeStrategy::Critical)
                node
              end
            end.to yield_control
          end

          context 'when root node refuted' do
            it 'transforms the error' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.refute(later_error)
              end

              expect(result.to_result.failure[:errors].map { |e| [e.code, e.message] })
                .to contain_exactly([:err1, 'Error 1'])
            end
          end

          context 'when child node disputed in a nested block' do
            it 'refutes the root node' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.refute(later_error, at: [:foo])
              end
              expect(result.to_result.failure[:errors].map { |e| [e.data[:path], e.message] })
                .to contain_exactly([[:foo], 'Error 1'])
            end
          end

          context 'when nested node is refuted directly' do
            it 'refutes the root node' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.at?(:foo, :bar) do |foo_bar|
                  foo_bar.refute(later_error)
                end
              end

              expect(result.to_result.failure[:errors].map { |e| [e.data[:path], e.message] })
                .to contain_exactly([%i[foo bar], 'Error 1'])
            end
          end

          context 'when nested node is refuted in validate? block' do
            it 'refutes the root node' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.at?(:foo, :bar) do |foo_bar|
                  foo_bar.validate? do |_value, _context|
                    Refute(later_error)
                  end
                end
              end
              expect(result.to_result.failure[:errors].map { |e| [e.data[:path], e.message] })
                .to contain_exactly([%i[foo bar], 'Error 1'])
            end
          end

          context 'when nested node is refuted in at block' do
            it 'refutes the root node' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.at(:foo) do |foo|
                  foo.at(:bar) do |bar|
                    bar.validate { |_value, _context| Refute(later_error) }
                  end
                end
              end
              expect(result.to_result.failure[:errors].map { |e| [e.data[:path], e.message] })
                .to contain_exactly([%i[foo bar], 'Error 1'])
            end
          end

          context 'when nested node is refuted during iteration' do
            it 'refutes the root node' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.each_at?(:foo, :bar) do |foo_bar_0|
                  foo_bar_0.validate? do |_value, _context|
                    Refute(later_error)
                  end
                end
              end
              expect(result.to_result.failure[:errors].map { |e| [e.data[:path], e.message] })
                .to contain_exactly([[:foo, :bar, 0], 'Error 1'])
            end
          end

          context 'when node is refuted at a nested path during iteration' do
            let(:value) { { array: [{ bar: 1 }, { bar: 2 }] } }

            it 'refutes the root node' do
              result = valid.critical(critical_error_rewrap) do |critical|
                critical.each_at(:array) do |element|
                  element.validate(:bar) do |_value, _context|
                    Refute(later_error)
                  end
                end
              end

              expect(result.to_result.failure[:errors].map { |e| [e.data[:path], e.message] })
                .to contain_exactly([[:array, 0, :bar], 'Error 1'])
            end
          end

          context 'when node with non-matching origin is returned' do
            include_context 'with fake validator'

            context 'with valid result' do
              it 'raises error' do
                expect do
                  valid.critical(critical_error_rewrap) { fake }
                end.to raise_error(Error, /Not the intent: \[\d+\] <> \[\d+\]/)
              end
            end
          end
        end

        context 'with committed result' do
          it 'yields critical node to the block' do
            expect { committed.critical(critical_error_rewrap) {} }
              .to raise_error(Error, "Can't reopen committed result")
          end
        end

        context 'with refuted result' do
          it "doesn't yield to block" do
            expect do |yield_probe|
              refuted.critical(critical_error_rewrap, &yield_probe)
            end.not_to yield_control
          end
        end
      end
    end
  end
end
