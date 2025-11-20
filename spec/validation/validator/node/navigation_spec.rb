# frozen_string_literal: true

require_relative '../support/shared/contexts/fake_validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Navigation do
          include Ruling::Constructors
          extend Dry::Monads[:maybe]

          let(:root) do
            Validator.instance(
              value,
              Support::Unit::Coordinators::Dry::Hierarchical,
              context: { foo: 'BAR' }
            )
          end
          let(:valid) { root }
          let(:refuted) { root.refute(first_error) }

          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
          let(:second_error) { StructuredError::Record.instance(:err1, message: 'Error 2') }

          describe '#at?' do
            let(:value) { { foo: { bar: 7 } } }

            context 'with immediate block' do
              context 'with refuted result' do
                it "doesn't yield to block" do
                  expect do |yield_probe|
                    refuted.at?(:foo, :bar, &yield_probe)
                  end.not_to yield_control
                end
              end

              context 'with valid result' do
                it 'yields validator into the block' do
                  expect do |yield_probe|
                    valid.at?(:foo, :bar) do |node|
                      yield_probe.to_proc.call
                      expect(node.value).to eq(7)
                      node
                    end
                  end.to yield_control
                end

                context 'when value is missing' do
                  it "doesn't yield into the block" do
                    expect do |yield_probe|
                      valid.at?(:foo, :bax, &yield_probe)
                    end.not_to yield_control
                  end
                end

                context 'when navigating to tuple' do
                  let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                  context 'when keys are present' do
                    it 'yields node into the block' do
                      expect do |yield_probe|
                        valid.at?([%i[foo number], %i[bar number]]) do |node|
                          yield_probe.to_proc.call
                          expect(node.value).to eq([7, 5])
                          node
                        end
                      end.to yield_control
                    end
                  end

                  context 'when some keys are missing' do
                    let(:value) { { foo: { number: 7 } } }

                    it "doesn't yield node into the block" do
                      expect do |yield_probe|
                        valid.at?([%i[foo number], %i[bar number]], &yield_probe)
                      end.not_to yield_control
                    end
                  end
                end

                context 'when nested node is disputed' do
                  it 'returns disputed result' do
                    disputed = valid.at?(:foo) do |node|
                      node.dispute(first_error)
                    end.dispute(second_error)
                    expect(disputed.to_result.failure)
                      .to eq({ errors: [second_error], children: { foo: { errors: [first_error] } } })
                  end
                end

                context 'when nested node is committed' do
                  it 'returns valid result with a committed nested result' do
                    disputed = valid.at?(:foo) do |node|
                      node.commit('FOO')
                    end.auto_commit(as: :hash)

                    expect(disputed.to_result.success)
                      .to eq({ foo: 'FOO' })
                  end
                end
              end
            end

            context 'when suspended with option' do
              it 'yields validator into the block' do
                expect do |yield_probe|
                  valid.at?(:foo, :bar).option do |node|
                    yield_probe.to_proc.call
                    expect(node.value.success).to eq(7)
                    node
                  end
                end.to yield_control
              end

              context 'when value is missing' do
                it 'yields node into the block' do
                  expect do |yield_probe|
                    valid.at?(:foo, :bax).option do |node|
                      yield_probe.to_proc.call
                      expect(node.value).to be_failure
                      node
                    end
                  end.to yield_control
                end
              end

              context 'when navigating to tuple' do
                let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                context 'when keys are present' do
                  it 'yields node into the block' do
                    expect do |yield_probe|
                      valid.at?([%i[foo number], %i[bar number]]).option do |node|
                        yield_probe.to_proc.call
                        expect(node.value).to eq([Some(7), Some(5)])
                        node
                      end
                    end.to yield_control
                  end
                end

                context 'when some keys are missing' do
                  let(:value) { { foo: { number: 7 } } }

                  it 'yields node into the block' do
                    expect do |yield_probe|
                      valid.at?([%i[foo number], %i[bar number]]).option do |node|
                        yield_probe.to_proc.call
                        expect(node.value).to eq([Some(7), None()])
                        node
                      end
                    end.to yield_control
                  end
                end
              end
            end

            context 'when suspended with some_or_nil' do
              it 'yields validator into the block' do
                expect do |yield_probe|
                  valid.at?(:foo, :bar).some_or_nil do |node|
                    yield_probe.to_proc.call
                    expect(node.value).to eq(7)
                    node
                  end
                end.to yield_control
              end

              context 'when value is missing' do
                it 'yields node into the block' do
                  expect do |yield_probe|
                    valid.at?(:foo, :bax).some_or_nil do |node|
                      yield_probe.to_proc.call
                      expect(node.value).to be_nil
                      node
                    end
                  end.to yield_control
                end
              end

              context 'when navigating to tuple' do
                let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                context 'when keys are present' do
                  it 'yields node into the block' do
                    expect do |yield_probe|
                      valid.at?([%i[foo number], %i[bar number]]).some_or_nil do |node|
                        yield_probe.to_proc.call
                        expect(node.value).to eq([7, 5])
                        node
                      end
                    end.to yield_control
                  end
                end

                context 'when some keys are missing' do
                  let(:value) { { foo: { number: 7 } } }

                  it 'yields node into the block' do
                    expect do |yield_probe|
                      valid.at?([%i[foo number], %i[bar number]]).some_or_nil do |node|
                        yield_probe.to_proc.call
                        expect(node.value).to eq([7, nil])
                        node
                      end
                    end.to yield_control
                  end
                end
              end
            end
          end

          describe '#at' do
            let(:value) { { foo: { bar: 7 } } }

            context 'with valid result' do
              it 'yields validator into the block' do
                expect do |yield_probe|
                  valid.at(:foo, :bar) do |node|
                    yield_probe.to_proc.call
                    expect(node.value).to eq(7)
                    node
                  end
                end.to yield_control
              end

              context 'when value is missing' do
                let(:expected_errors) do
                  {
                    children: {
                      foo: {
                        children: {
                          bax: {
                            errors: [have_attributes(code: :value_missing)]
                          }
                        }
                      }
                    }
                  }
                end

                it 'refutes missing key' do
                  expect(valid.at(:foo, :bax) {}.to_result.failure)
                    .to match(expected_errors)
                end
              end

              context 'when navigating to tuple' do
                let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                context 'when keys are present' do
                  it 'yields node into the block' do
                    expect do |yield_probe|
                      valid.at([%i[foo number], %i[bar number]]) do |node|
                        yield_probe.to_proc.call
                        expect(node.value).to eq([7, 5])
                        node
                      end
                    end.to yield_control
                  end
                end

                context 'when some keys are missing' do
                  let(:value) { { foo: { number: 7 } } }

                  it 'refutes the key' do
                    result = valid.at(:sum, from: [[%i[foo number], %i[bar number]]]) {}
                    expect(result.to_result.failure)
                      .to match({ children: { sum: { errors: [have_attributes(code: :value_missing)] } } })
                  end
                end
              end
            end

            context 'when node with non-matching origin is returned' do
              include_context 'with fake validator'

              context 'with valid result' do
                it 'raises error' do
                  expect do
                    valid.at(:foo) { fake.refute(first_error) }
                  end.to raise_error(Error, /Not the intent: \[\d+,foo\] <> \[\d+\]/)
                end
              end
            end
          end
        end
      end
    end
  end
end
