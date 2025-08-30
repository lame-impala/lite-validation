# frozen_string_literal: true

require_relative '../../../../../../lib/lite/validation/validator'

module Lite
  module Validation
    module Validator
      module Support
        module Functional
          module Contracts
            module Hash
              VALID = {
                id: 'o1',
                price: 120_00,
                dates: {
                  issued: '2025-08-15',
                  due: '2025-08-31'
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
                  { amount: 60_00, type: 'card' },
                  { amount: 60_00, type: 'cash' }
                ]
              }.freeze

              INVALID = {
                id: 'o1',
                price: 121_00,
                dates: {
                  issued: '2025-08-31',
                  due: '2025-08-15'
                },
                payments: [
                  { amount: nil, type: 'card' },
                  { amount: 60_00, type: 'coupon' }
                ],
                items: [
                  { id: 'i1', name: 'I1', qty: -1, price: 10_00 },
                  { id: nil, name: 'I2', qty: 1, price: -1 }
                ]
              }.freeze

              CONTEXT = { limit: 120_00 }.freeze

              extend Ruling::Constructors

              def self.call(data, coordinator, context)
                Validator
                  .instance(data, coordinator, context: context)
                  .satisfy(:id, commit: true) { :presence }
                  .satisfy(:price, severity: :refute) { :positive_number }
                  .validate(:price) { |price, context| price <= context[:limit] ? Commit(price) : Dispute(:excessive) }
                  .at(:dates) { |dates| dates(dates) }
                  .at(:payments) { |payments| payments(payments) }
                  .at(:items) { |items| items(items) }
                  .auto_commit(as: :hash)
              end

              def self.dates(dates)
                dates
                  .satisfy(:issued) { :presence }
                  .satisfy(:due) { :presence }
                  .with_valid { |valid| valid.satisfy(%i[due issued], using: :dry) { _1.call { lt? } } }
                  .validate(:issued) { |issued| Commit(DateTime.parse(issued)) }
                  .validate(:due) { |due| Commit(DateTime.parse(due)) }
                  .auto_commit(as: :hash)
              end

              def self.payments(payments)
                payments.each_at(commit: :array) do |payment|
                  payment
                    .satisfy(:amount, commit: true) { :positive_number }
                    .satisfy(:type, using: :dry, commit: true) { _1.call { included_in? %w[cash card] } }
                    .auto_commit(as: :hash)
                end
              end

              def self.items(items)
                items.each_at(commit: :array) do |item|
                  item
                    .satisfy(:id, commit: true) { :presence }
                    .satisfy(:name, commit: true) { :presence }
                    .satisfy(:price, commit: true) { :positive_number }
                    .satisfy(:qty, commit: true) { :positive_number }
                    .auto_commit(as: :hash)
                end
              end
            end
          end
        end
      end
    end
  end
end
