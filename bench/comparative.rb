# frozen_string_literal: true

require 'benchmark'
require 'active_model'
require 'dry/validation'
require 'byebug'

require_relative '../spec/validation/validator/support/functional/contracts/hash'
require_relative '../spec/validation/validator/support/functional/coordinators/dry'
require_relative '../spec/validation/validator/support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      module Benchmark
        module Comparative
          class DryBench < Dry::Validation::Contract
            option(:limit)

            json do
              required(:id).filled(:string)
              required(:price).value(:integer, gteq?: 0)
              required(:dates).schema do
                required(:issued).value(:date_time)
                required(:due).value(:date_time)
              end
              required(:payments).array do
                schema do
                  required(:amount).value(:integer, gteq?: 0)
                  required(:type).value(:string, included_in?: %w[card cash])
                end
              end
              required(:items).array do
                schema do
                  required(:id).filled(:string)
                  required(:name).filled(:string)
                  required(:price).value(:integer, gteq?: 0)
                  required(:qty).value(:integer, gteq?: 0)
                end
              end
            end

            rule(dates: %i[issued due]) do
              next if value[0] <= value[1]

              key.failure('first must be less than or equal to the second')
            end

            rule(:price) do
              next if value <= limit

              key.failure('is excessive')
            end
          end

          class ActiveModelBench < Dry::Validation::Contract
            def self.call(data, limit:)
              model ||= BenchModel.instance(data, limit: limit)
              model.valid? ? nil : model.errors
            end

            class BenchModel
              def self.instance(data, limit:)
                dates = Dates.new(**data[:dates])
                items = data[:items].map { Item.new(**data.slice(:id, :name, :price, :qty)) }
                payments = data[:payments].map { Payment.new(**data.slice(:amount, :type)) }

                BenchModel.new(dates: dates, items: items, payments: payments, limit: limit, **data.slice(:id, :price))
              end

              class Dates
                include ActiveModel::Model
                include ActiveModel::Attributes
                include ActiveModel::Validations

                attribute :issued, :datetime
                attribute :due, :datetime

                validates :issued, presence: true
                validates :due, presence: true

                validate do
                  next if issued < due

                  errors.add('(issued,due)', 'first must be less than or equal to the second')
                end
              end

              class Payment
                include ActiveModel::Model
                include ActiveModel::Attributes
                include ActiveModel::Validations

                attribute :amount, :integer
                attribute :type, :string

                validates :amount, presence: true, numericality: { greater_than: 0 }
                validates :type, presence: true, inclusion: %w[cash card]
              end

              class Item
                include ActiveModel::Model
                include ActiveModel::Attributes
                include ActiveModel::Validations

                attribute :id, :string
                attribute :name, :string
                attribute :price, :integer
                attribute :qty, :integer

                validates :price, presence: true, numericality: { greater_than: 0 }
                validates :qty, presence: true, numericality: { greater_than: 0 }
              end

              include ActiveModel::Model
              include ActiveModel::Attributes
              include ActiveModel::Validations

              attribute :id, :string
              attribute :price, :integer
              attribute :limit, :integer
              attribute :dates
              attribute :items
              attribute :payments

              validates :id, presence: true
              validates :price, presence: true

              validate do
                next if dates.valid?

                dates.errors.messages.each { |attr, msg| errors.add("dates.#{attr}", msg) }
              end

              validate do
                items.each_with_index do |item, idx|
                  next if item.valid?

                  item.errors.messages.each { |attr, msg| errors.add("items.#{idx}.#{attr}", msg) }
                end
              end

              validate do
                payments.each_with_index do |payment, idx|
                  next if payment.valid?

                  payment.errors.messages.each { |attr, msg| errors.add("payments.#{idx}.#{attr}", msg) }
                end
              end

              validate do
                errors.add(:price, 'is excessive') if price > limit
              end
            end
          end

          LiteBench = Support::Functional::Contracts::Hash

          VALID = LiteBench::VALID
          INVALID = LiteBench::INVALID
          CONTEXT = LiteBench::CONTEXT

          def self.run(n) # rubocop:disable Naming/MethodParameterName, Metrics/AbcSize
            runs = {}

            runs[:ActiveModel] = proc do |idx|
              ActiveModelBench.call(data(idx), **CONTEXT)
            end

            runs[:Dry] = proc do |idx|
              DryBench.new(**CONTEXT).call(data(idx))
            end

            runs[:Lite] = proc do |idx|
              LiteBench.call(
                data(idx),
                Support::Functional::Coordinators::Dry::Flat,
                CONTEXT
              ).to_result
            end

            runs.to_a.shuffle.each do |key, proc|
              result = ::Benchmark.measure { n.times { |idx| proc.call(idx) } }
              puts "#{key}: #{result}"
            end
          end

          def self.data(idx)
            (idx % 5).zero? ? INVALID : VALID
          end
        end
      end
    end
  end
end

Lite::Validation::Validator::Benchmark::Comparative.run(1000)
