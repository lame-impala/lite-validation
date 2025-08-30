# frozen_string_literal: true

require_relative '../support/unit/validator'
require_relative '../support/unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Node
        RSpec.describe Implementation::Validation do
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
          let(:refuted) { root.refute(first_error) }

          let(:first_error) { StructuredError::Record.instance(:err1, message: 'Error 1') }
          let(:second_error) { StructuredError::Record.instance(:err1, message: 'Error 2') }

          describe '#validate?' do
            let(:value) { { foo: 'FOO' } }

            context 'with refuted result' do
              it "doesn't yield to block" do
                expect do |yield_probe|
                  refuted.validate?(:foo, &yield_probe)
                end.not_to yield_control
              end
            end

            context 'with disputable result' do
              context 'with immediate block' do
                context 'when value is present' do
                  it 'yields value to the block' do
                    expect do |yield_probe|
                      valid.validate?(:foo) do |value, _context|
                        yield_probe.to_proc.call
                        expect(value).to eq('FOO')
                        Pass()
                      end
                    end.to yield_control
                  end
                end

                context 'when value is missing' do
                  it "doesn't yield to block" do
                    expect do |yield_probe|
                      valid.validate?(:bar, &yield_probe)
                    end.not_to yield_control
                  end
                end

                context 'when validating tuple' do
                  let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                  context 'when keys are present' do
                    it 'yields tuple of values into the block' do
                      result = valid.validate?(:sum, from: [[%i[foo number], %i[bar number]]]) do |(foo, bar)|
                        expect([foo, bar]).to eq([7, 5])
                        Dispute(first_error)
                      end
                      expect(result.to_result.failure)
                        .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                    end
                  end

                  context 'when some keys are missing' do
                    let(:value) { { foo: { number: 7 } } }

                    it "doesn't yield into the block" do
                      expect do |yield_probe|
                        valid.validate?([%i[foo number], %i[bar number]], &yield_probe)
                      end.not_to yield_control
                    end
                  end
                end
              end

              context 'when suspended as some' do
                context 'when value is present' do
                  it 'yields value to the block' do
                    expect do |yield_probe|
                      valid.validate?(:foo).some do |value, _context|
                        yield_probe.to_proc.call
                        expect(value).to eq('FOO')
                        Pass()
                      end
                    end.to yield_control
                  end

                  context 'with commit as true' do
                    let(:committed) { valid.validate?(:foo, commit: true).some { nil }.auto_commit(as: :hash) }

                    it 'commits the value' do
                      expect(committed.to_result.success)
                        .to eq({ foo: 'FOO' })
                    end
                  end
                end

                context 'when value is missing' do
                  it "doesn't yield to block" do
                    expect do |yield_probe|
                      valid.validate?(:bar).some(&yield_probe)
                    end.not_to yield_control
                  end
                end

                context 'when validating tuple' do
                  let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                  context 'when keys are present' do
                    it 'yields tuple of values into the block' do
                      result = valid.validate?(:sum, from: [[%i[foo number], %i[bar number]]]).some do |(foo, bar)|
                        expect([foo, bar]).to eq([7, 5])
                        Dispute(first_error)
                      end
                      expect(result.to_result.failure)
                        .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                    end
                  end

                  context 'when some keys are missing' do
                    let(:value) { { foo: { number: 7 } } }

                    it "doesn't yield into the block" do
                      expect do |yield_probe|
                        valid.validate?([%i[foo number], %i[bar number]]).some(&yield_probe)
                      end.not_to yield_control
                    end
                  end
                end
              end

              context 'when suspended as option' do
                context 'when value is present' do
                  it 'yields some to the block' do
                    expect do |yield_probe|
                      valid.validate?(:foo).option do |value, _context|
                        yield_probe.to_proc.call
                        expect(value.success).to eq('FOO')
                        Pass()
                      end
                    end.to yield_control
                  end

                  context 'with commit as true' do
                    let(:committed) { valid.validate?(:foo, commit: true).option { nil }.auto_commit(as: :hash) }

                    it 'commits the option' do
                      expect(committed.to_result.success)
                        .to eq({ foo: Dry::Monads::Success('FOO') })
                    end
                  end
                end

                context 'when value is missing' do
                  it 'yields none to the block' do
                    expect do |yield_probe|
                      valid.validate?(:bar).option do |option, _context|
                        yield_probe.to_proc.call
                        expect(option).to be_failure
                        Pass()
                      end
                    end.to yield_control
                  end

                  context 'with commit as true' do
                    let(:committed) { valid.validate?(:bar, commit: true).option { nil }.auto_commit(as: :hash) }

                    it 'commits the option' do
                      expect(committed.to_result.success)
                        .to eq({ bar: Dry::Monads::Failure(Dry::Monads::Unit) })
                    end
                  end
                end

                context 'when validating tuple' do
                  let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                  context 'when keys are present' do
                    it 'yields tuple of options into the block' do
                      result = valid.validate?(:sum, from: [[%i[foo number], %i[bar number]]]).option do |(foo, bar)|
                        expect([foo.success, bar.success]).to eq([7, 5])
                        Dispute(first_error)
                      end
                      expect(result.to_result.failure)
                        .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                    end
                  end

                  context 'when some keys are missing' do
                    let(:value) { { foo: { number: 7 } } }

                    it 'yields tuple of options into the block' do
                      result = valid.validate?(:sum, from: [[%i[foo number], %i[bar number]]]).option do |(foo, bar)|
                        expect([foo.success?, bar.success?]).to eq([true, false])
                        Dispute(first_error)
                      end
                      expect(result.to_result.failure)
                        .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                    end
                  end
                end
              end

              context 'when suspended as some_or_nil' do
                context 'when value is present' do
                  it 'yields value to the block' do
                    expect do |yield_probe|
                      valid.validate?(:foo).some_or_nil do |value, _context|
                        yield_probe.to_proc.call
                        expect(value).to eq('FOO')
                        Pass()
                      end
                    end.to yield_control
                  end

                  context 'with commit as true' do
                    let(:committed) { valid.validate?(:foo, commit: true).some_or_nil { nil }.auto_commit(as: :hash) }

                    it 'commits the value' do
                      expect(committed.to_result.success)
                        .to eq({ foo: 'FOO' })
                    end
                  end
                end

                context 'when value is missing' do
                  it 'yields nil to the block' do
                    expect do |yield_probe|
                      valid.validate?(:bar).some_or_nil do |value, _context|
                        yield_probe.to_proc.call
                        expect(value).to be_nil
                        Pass()
                      end
                    end.to yield_control
                  end

                  context 'with commit as true' do
                    let(:committed) { valid.validate?(:bar, commit: true).some_or_nil { nil }.auto_commit(as: :hash) }

                    it 'commits nil' do
                      expect(committed.to_result.success)
                        .to eq({ bar: nil })
                    end
                  end
                end

                context 'when validating tuple' do
                  let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                  context 'when keys are present' do
                    it 'yields tuple of values into the block' do
                      result = valid.validate?(:sum, from: [[%i[foo number], %i[bar number]]]).some_or_nil do |(foo, bar)|
                        expect([foo, bar]).to eq([7, 5])
                        Dispute(first_error)
                      end
                      expect(result.to_result.failure)
                        .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                    end
                  end

                  context 'when some keys are missing' do
                    let(:value) { { foo: { number: 7 } } }

                    it 'yields tuple of values into the block' do
                      result = valid.validate?(:sum, from: [[%i[foo number], %i[bar number]]]).some_or_nil do |(foo, bar)|
                        expect([foo, bar]).to eq([7, nil])
                        Dispute(first_error)
                      end
                      expect(result.to_result.failure)
                        .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                    end
                  end
                end
              end
            end
          end

          describe '#validate' do
            context 'when validating at root level' do
              context 'with refuted result' do
                it "doesn't yield to block" do
                  expect do |yield_probe|
                    refuted.validate(&yield_probe)
                  end.not_to yield_control
                end
              end

              context 'with valid result' do
                context 'when Pass is returned' do
                  let(:passed) { root.validate { nil } }

                  it 'returns valid result' do
                    expect(passed.to_result.success).to eq(5)
                  end
                end

                context 'when committed result is returned' do
                  let(:committed) { root.validate { Commit(2) } }

                  it 'returns success' do
                    expect(committed.to_result.success).to eq(2)
                  end
                end

                context 'when Dispute is returned' do
                  let(:disputed) do
                    root.validate { Dispute(first_error) }
                        .validate { Dispute(second_error) }
                  end

                  it 'returns disputed result' do
                    expect(disputed.to_result.failure).to eq({ errors: [first_error, second_error] })
                  end
                end

                context 'when Refute is returned' do
                  let(:refuted) do
                    root.validate { Refute(first_error) }
                        .validate { Refute(second_error) }
                  end

                  it 'returns refuted' do
                    expect(refuted.to_result.failure).to eq({ errors: [first_error] })
                  end
                end
              end
            end

            context 'when validating at child level' do
              let(:value) { { foo: 'FOO' } }

              context 'with refuted result' do
                it "doesn't yield to block" do
                  expect do |yield_probe|
                    refuted.validate(:foo, &yield_probe)
                  end.not_to yield_control
                end
              end

              context 'with valid result' do
                context 'when Pass is returned' do
                  let(:passed) { root.validate(:foo) { nil } }

                  it 'returns valid result' do
                    expect(passed.to_result.success).to eq({ foo: 'FOO' })
                  end

                  context 'with commit as true' do
                    let(:committed) { root.validate(:foo, commit: true) { nil }.auto_commit(as: :hash) }

                    it 'commits the value' do
                      expect(committed.to_result.success)
                        .to eq({ foo: 'FOO' })
                    end
                  end
                end

                context 'when committed result is returned' do
                  let(:committed) { root.validate(:foo) { Commit('BAR') } }

                  it 'returns success' do
                    expect(committed.auto_commit(as: :hash).to_result.success).to eq({ foo: 'BAR' })
                  end

                  context 'with commit as true' do
                    let(:doubly_committed) { root.validate(:foo, commit: true) { Commit('BAR') } }

                    it 'raises error' do
                      expect { doubly_committed }.to raise_error(Error, "Can't reopen committed result")
                    end
                  end
                end

                context 'when Dispute is returned' do
                  let(:disputed) do
                    root.validate(:foo) { Dispute(first_error) }
                        .validate(:foo) { Dispute(second_error) }
                  end

                  it 'returns disputed result' do
                    expect(disputed.to_result.failure)
                      .to eq({ children: { foo: { errors: [first_error, second_error] } } })
                  end
                end

                context 'when Refute is returned' do
                  let(:refuted) do
                    root.validate(:foo) { Refute(first_error) }
                        .validate(:foo) { Refute(second_error) }
                  end

                  it 'returns disputed root with refuted child' do
                    expect(refuted.to_result.failure)
                      .to eq({ children: { foo: { errors: [first_error] } } })
                  end
                end
              end

              context 'when validating tuple' do
                let(:value) { { foo: { number: 7 }, bar: { number: 5 } } }

                context 'when keys are present' do
                  it 'yields tuple of values into the block' do
                    result = valid.validate(:sum, from: [[%i[foo number], %i[bar number]]]) do |(foo, bar)|
                      expect([foo, bar]).to eq([7, 5])
                      Dispute(first_error)
                    end
                    expect(result.to_result.failure)
                      .to match({ children: { sum: { errors: [have_attributes(code: :err1)] } } })
                  end
                end

                context 'when some keys are missing' do
                  let(:value) { { foo: { number: 7 } } }

                  it 'refutes the key' do
                    result = valid.validate(:sum, from: [[%i[foo number], %i[bar number]]]) do |_tuple, _context|
                      Dispute(first_error)
                    end
                    expect(result.to_result.failure)
                      .to match({ children: { sum: { errors: [have_attributes(code: :value_missing)] } } })
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
