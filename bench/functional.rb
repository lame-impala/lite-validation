# frozen_string_literal: true

require 'benchmark'
require 'dry/validation'
require 'byebug'

require_relative '../lib/lite/validation/validator'
require_relative '../spec/validation/validator/support/functional/coordinators/dry'
require_relative '../spec/validation/validator/support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      module Benchmark
        module Functional
          module Iteration
            def self.run(n) # rubocop:disable Naming/MethodParameterName, Metrics/AbcSize
              runs = {}

              runs[:IndirectValidate] = proc do |_idx|
                IndirectIterationValidate.call(validate_data)
              end

              runs[:DirectValidate] = proc do |_idx|
                DirectIterationValidate.call(validate_data)
              end

              runs[:DirectSatisfy] = proc do |_idx|
                DirectIterationSatisfy.call(satisfy_data)
              end

              runs.to_a.shuffle.each do |key, proc|
                result = ::Benchmark.measure { n.times { |idx| proc.call(idx) } }
                puts "#{key}: #{result}"
              end
            end

            def self.validate_data
              array = 100.times.map do
                rand = rand()
                case rand
                when 11 then nil
                else rand
                end
              end

              { array: array }
            end

            def self.satisfy_data
              { array: 100.times.map { rand } }
            end

            def self.rand
              Random.rand(-1..11)
            end

            module IndirectIterationValidate
              extend Ruling::Constructors

              def self.call(data, coordinator: Support::Functional::Coordinators::Dry::Flat)
                Validator
                  .instance(data, coordinator)
                  .each_at(:array, commit: :array) do |node|
                  node
                    .validate(commit: true) do |value, _ctx|
                    next Refute(:blank) if value.nil?

                    Dispute(:negative) if value.negative?
                  end
                end.auto_commit(as: :hash)
              end
            end

            module DirectIterationValidate
              extend Ruling::Constructors

              def self.call(data, coordinator: Support::Functional::Coordinators::Dry::Flat)
                Validator
                  .instance(data, coordinator)
                  .each_at(:array, commit: :array).validate(commit: true) do |value, _ctx|
                  next Refute(:blank) if value.nil?

                  Dispute(:negative) if value.negative?
                end.auto_commit(as: :hash)
              end
            end

            module DirectIterationSatisfy
              extend Ruling::Constructors

              def self.call(data, coordinator: Support::Functional::Coordinators::Dry::Flat)
                Validator
                  .instance(data, coordinator, context: { min: 0, max: 10 })
                  .each_at(:array, commit: :array).satisfy(using: :dry, commit: true) do |builder, context|
                  builder.call { gteq?(context[:min]) & lteq?(context[:max]) }
                end.auto_commit(as: :array)
              end
            end
          end
        end
      end
    end
  end
end

Lite::Validation::Validator::Benchmark::Functional::Iteration.run(2000)
