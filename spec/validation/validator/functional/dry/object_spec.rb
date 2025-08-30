# frozen_string_literal: true

require_relative '../../support/functional/coordinators/dry'
require_relative '../../support/shared/predicates/dry'
require_relative '../../support/shared/contexts/critical_error_rewrap'

module Lite
  module Validation
    module Validator
      class TestModel
        class Item
          Lite::Data.define(self, args: [:id], kwargs: %i[name price quantity])
        end

        Lite::Data.define(self, args: [:id], kwargs: %i[items issued_date due_date charges tax])

        def subtotal
          items.sum { |item| item.price * item.quantity }
        rescue StandardError => _e
          nil
        end

        def total
          operands = [subtotal, charges, tax]
          return if operands.any?(&:nil?)

          operands.sum
        end

        def initialize(*args, items: [], **opts)
          super
        end
      end

      RSpec.describe 'Dry' do
        include_context 'with critical error rewrap'
        include Ruling::Constructors

        subject(:result) do
          Validator.instance(model, coordinator, context: { limit: 600 }).at do |model|
            model.critical(critical_error_rewrap) do |critical|
              critical
                .satisfy(:charges, severity: :refute) { :positive_number }
                .satisfy(:tax, severity: :refute) { :positive_number }
            end.critical(critical_error_rewrap) do |critical|
              critical.each_at(:items) do |item|
                item
                  .satisfy(:price, severity: :refute) { :positive_number }
                  .satisfy(:quantity, severity: :refute) { :positive_number }
              end
            end.with_valid do |valid|
              valid.validate(:total) do |total, context|
                Refute(:excessive) if total > context[:limit]
              end
            end.satisfy(:issued_date) { :presence }
                 .with_valid(:issued_date) do |model|
              model.validate(%i[issued_date due_date]) do |(issued_date, due_date), _context|
                next if due_date.nil? || due_date > issued_date

                Dispute(:invalid, message: 'first must be less than or equal to the second')
              end
            end
          end.to_result
        end
        let(:coordinator) { Support::Functional::Coordinators::Dry::Flat }

        context 'with valid model' do
          let(:model) do
            TestModel.new(
              'tm_valid',
              items: [
                TestModel::Item.new('sp1', name: 'Spare part 1', price: 100, quantity: 1),
                TestModel::Item.new('sp2', name: 'Spare part 2', price: 200, quantity: 2)
              ],
              issued_date: '2025-08-01',
              due_date: '2025-08-15',
              charges: 20,
              tax: 32
            )
          end

          it 'is success' do
            expect(result).to be_success
          end
        end

        context 'with invalid model' do
          let(:model) do
            TestModel.new(
              'tm_excessive',
              items: [TestModel::Item.new('sp1', name: 'Spare part 1', price: 100, quantity: 10)],
              issued_date: '2025-08-01',
              due_date: '2025-07-15',
              charges: 20,
              tax: 32
            )
          end

          let(:expected_errors) do
            [
              ['total', [:excessive]],
              ['(issued_date,due_date)', [:invalid]]
            ]
          end

          it 'reports errors' do
            expect(result.failure.map { |(key, errors)| [key, errors.map(&:code)] })
              .to eq(expected_errors)
          end
        end

        context 'with invalid charge' do
          let(:model) do
            TestModel.new(
              'tm_invalid_charge',
              items: [TestModel::Item.new('sp1', name: 'Spare part 1', price: 100, quantity: 10)],
              issued_date: '2025-08-01',
              due_date: '2025-07-15',
              charges: nil,
              tax: 32
            )
          end

          let(:expected_errors) do
            [['', [{ code: :'failed: number? AND gt?(0)', data: { path: [:charges], original_data: nil } }]]]
          end

          it 'reports error' do
            expect(result.failure.map { |(key, errors)| [key, errors.map(&:to_hash)] })
              .to eq(expected_errors)
          end
        end

        context 'with invalid item' do
          let(:model) do
            TestModel.new(
              'tm_invalid_item',
              items: [
                TestModel::Item.new('sp1', name: 'Spare part 1', price: 100, quantity: nil),
                TestModel::Item.new('sp2', name: 'Spare part 2', price: nil, quantity: 2)
              ],
              issued_date: '2025-08-01',
              due_date: '2025-07-15',
              charges: 20,
              tax: 32
            )
          end

          let(:expected_errors) do
            merged_error = {
              code: :'failed: number? AND gt?(0)',
              data: {
                path: [:items, 0, :quantity],
                original_data: nil
              }
            }
            [['', [merged_error]]]
          end

          it 'reports error' do
            expect(result.failure.map { |(key, errors)| [key, errors.map(&:to_hash)] })
              .to eq(expected_errors)
          end
        end

        context 'with invalid issued date' do
          let(:model) do
            TestModel.new(
              'tm_invalid_issued_date',
              items: [
                TestModel::Item.new('sp1', name: 'Spare part 1', price: 100, quantity: 1),
                TestModel::Item.new('sp2', name: 'Spare part 2', price: 200, quantity: 2)
              ],
              issued_date: nil,
              due_date: '2025-07-15',
              charges: 20,
              tax: 32
            )
          end

          let(:expected_errors) do
            [['issued_date', [:blank]]]
          end

          it 'is success' do
            expect(result.failure.map { |(key, errors)| [key, errors.map(&:code)] })
              .to eq(expected_errors)
          end
        end
      end
    end
  end
end
