# frozen_string_literal: true

require 'benchmark'
require 'active_model'
require 'dry/validation'
require 'byebug'

require_relative '../../lib/lite/validation/validator'
require_relative '../../spec/validation/validator/support/functional/coordinators/dry'

module Lite
  module Validation
    module Validator
      module Benchmark
        module Comparative
          module Transformation
            INPUT = {
              customer: { name: 'John Doe' },
              items: [
                { price: '100', name: 'Item 1' },
                { price: '200', name: 'Item 2' }
              ],
              charges: [
                { price: '50', name: 'Charge 1' }
              ],
              item_total: '300',
              charge_total: '50'
            }.freeze

            module HashBench
              def self.call(input)
                {
                  customer_name: input.dig(:customer, :name),
                  line_items: line_items(input[:items]),
                  charges: charges(input[:charges]),
                  total: input[:item_total].to_i + input[:charge_total].to_i
                }
              end

              def self.line_items(items)
                items.map { { unit_price: _1[:price].to_i, name: _1[:name] } }
              end

              def self.charges(charges)
                charges.map { { amount: _1[:price].to_i, name: _1[:name] } }
              end
            end

            module LiteBench
              def self.call(input)
                Validator
                  .instance(input, Support::Functional::Coordinators::Dry::Flat)
                  .transform(:customer_name, from: %i[customer name]) { _1 }
                  .each_at(:line_items, from: [:items], commit: :array) { line_item(_1) }
                  .each_at(:charges, commit: :array) { charge(_1) }
                  .transform(:total, from: [%i[item_total charge_total]]) { _1.map(&:to_i).sum }
                  .auto_commit(as: :hash)
              end

              def self.line_item(item)
                item
                  .transform(:unit_price, from: %i[price]) { _1.to_i }
                  .transform(:name) { _1 }
                  .auto_commit(as: :hash)
              end

              def self.charge(charge)
                charge
                  .transform(:amount, from: %i[price]) { _1.to_i }
                  .transform(:name) { _1 }
                  .auto_commit(as: :hash)
              end
            end

            def self.run(n) # rubocop:disable Naming/MethodParameterName
              runs = {}

              runs[:Hash] = proc do
                HashBench.call(INPUT)
              end

              runs[:Lite] = proc do
                LiteBench.call(INPUT).to_result.success
              end

              runs.to_a.shuffle.each do |key, proc|
                result = ::Benchmark.measure { n.times { proc.call } }
                puts "#{key}: #{result}"
              end
            end
          end
        end
      end
    end
  end
end

Lite::Validation::Validator::Benchmark::Comparative::Transformation.run(10_000)
