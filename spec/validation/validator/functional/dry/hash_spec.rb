# frozen_string_literal: true

require_relative '../../support/functional/contracts/hash'
require_relative '../../support/functional/coordinators/dry'
require_relative '../../support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      RSpec.describe 'Dry' do
        let(:result) { contract.call(data, coordinator, context).to_result }
        let(:contract) { Support::Functional::Contracts::Hash }
        let(:context) { Support::Functional::Contracts::Hash::CONTEXT }

        context 'with valid data' do
          let(:data) { Support::Functional::Contracts::Hash::VALID }
          let(:coordinator) { Support::Functional::Coordinators::Dry::Hierarchical }

          let(:expected_result) do
            {
              id: 'o1',
              price: 120_00,
              dates: {
                due: DateTime.parse('2025-08-31'),
                issued: DateTime.parse('2025-08-15')
              },
              items: [
                { id: 'i1', name: 'I1', qty: 2, price: 10_00 },
                { id: 'i2', name: 'I2', qty: 1, price: 5_00 },
                { id: 'i3', name: 'I3', qty: 1, price: 7_00 },
                { id: 'i4', name: 'I4', qty: 1, price: 18_00 },
                { id: 'i5', name: 'I5', qty: 1, price: 3_00 },
                { id: 'i6', name: 'I6', qty: 1, price: 15_00 },
                { id: 'i7', name: 'I7', qty: 1, price: 13_00 },
                { id: 'i8', name: 'I8', qty: 1, price: 19_00 },
                { id: 'i9', name: 'I9', qty: 1, price: 8_00 },
                { id: 'i10', name: 'I10', qty: 1, price: 12_00 }
              ],
              payments: [
                { amount: 60_00, :type => 'card' },
                { amount: 60_00, :type => 'cash' }
              ]
            }
          end

          it 'transforms the data into a new structure' do
            expect(result.success).to eq(expected_result)
          end
        end

        context 'with invalid data' do
          let(:data) { Support::Functional::Contracts::Hash::INVALID }

          context 'with hierarchical error builder' do
            let(:coordinator) { Support::Functional::Coordinators::Dry::Hierarchical }

            let(:expected_errors) do
              {
                children: {
                  dates: {
                    children: {
                      %i[due issued] => { errors: [have_attributes(code: :'failed: lt?')] }
                    }
                  },
                  items: {
                    children: {
                      0 => {
                        children: {
                          qty: {
                            errors: [have_attributes(code: :'failed: number? AND gt?(0)')]
                          }
                        }
                      },
                      1 => {
                        children: {
                          id: {
                            errors: [have_attributes(code: :blank)]
                          },
                          price: {
                            errors: [have_attributes(code: :'failed: number? AND gt?(0)')]
                          }
                        }
                      }
                    }
                  },
                  payments: {
                    children: {
                      0 => {
                        children: {
                          amount: {
                            errors: [have_attributes(code: :'failed: number? AND gt?(0)')]
                          }
                        }
                      },
                      1 => {
                        children: {
                          type: {
                            errors: [have_attributes(code: :'failed: included_in?(["cash", "card"])')]
                          }
                        }
                      }
                    }
                  },
                  price: {
                    errors: [have_attributes(code: :excessive)]
                  }
                }
              }
            end

            it 'builds errors' do
              expect(result.failure).to match(expected_errors)
            end
          end

          context 'with dry error builder' do
            let(:coordinator) { Support::Functional::Coordinators::Dry::Dry }

            let(:expected_errors) do
              {
                dates: {
                  %i[due issued] => [have_attributes(code: :'failed: lt?')]
                },
                items: {
                  0 => {
                    qty: [have_attributes(code: :'failed: number? AND gt?(0)')]
                  },
                  1 => {
                    id: [have_attributes(code: :blank)],
                    price: [have_attributes(code: :'failed: number? AND gt?(0)')]
                  }
                },
                payments: {
                  0 => {
                    amount: [have_attributes(code: :'failed: number? AND gt?(0)')]
                  },
                  1 => {
                    type: [have_attributes(code: :'failed: included_in?(["cash", "card"])')]
                  }
                },
                price: [have_attributes(code: :excessive)]
              }
            end

            it 'builds errors' do
              expect(result.failure).to match(expected_errors)
            end
          end

          context 'with flat error builder' do
            let(:coordinator) { Support::Functional::Coordinators::Dry::Flat }

            let(:expected_errors) do
              [
                ['price', [have_attributes(code: :excessive)]],
                ['dates.(due,issued)', [have_attributes(code: :'failed: lt?')]],
                ['payments.0.amount', [have_attributes(code: :'failed: number? AND gt?(0)')]],
                ['payments.1.type', [have_attributes(code: :'failed: included_in?(["cash", "card"])')]],
                ['items.0.qty', [have_attributes(code: :'failed: number? AND gt?(0)')]],
                ['items.1.id', [have_attributes(code: :blank)]],
                ['items.1.price', [have_attributes(code: :'failed: number? AND gt?(0)')]]
              ]
            end

            it 'builds errors' do
              expect(result.failure).to match(expected_errors)
            end
          end
        end
      end
    end
  end
end
