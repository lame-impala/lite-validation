# frozen_string_literal: true

require 'benchmark'
require 'dry/validation'
require 'byebug'

require_relative '../spec/validation/validator/result/support/test_reducer'

module Lite
  module Validation
    module Validator
      module Benchmark
        module Calibrational
          module Iteration
            def self.run(n, k) # rubocop:disable Naming/MethodParameterName, Metrics/AbcSize
              runs = {}

              runs[:ValidArrayValues] = proc do |_idx|
                ValidArrayValues.call(data(k), block)
              end

              runs[:ValidArrayTuples] = proc do |_idx|
                ValidArrayTuples.call(data(k), block)
              end

              runs[:ValidHash] = proc do |_idx|
                ValidHash.call(data(k), block)
              end

              runs.to_a.each do |key, proc|
                result = ::Benchmark.measure { n.times { proc.call } }
                puts "#{key}: #{result}"
              end
            end

            def self.data(k) # rubocop:disable Naming/MethodParameterName
              k.times.map do
                Random.rand(0...100)
              end
            end

            def self.block
              lambda { |_iterable, _key, value, result, _context|
                if value.negative?
                  result
                else
                  [result.commit(value + 1), nil]
                end
              }
            end

            module ValidArrayValues
              def self.call(data, block)
                iterable = Result::Valid::Iterable::Array::Values.instance
                Node::TestReducer.reduce(iterable, data, block).navigable
              end
            end

            module ValidArrayTuples
              def self.call(data, block)
                iterable = Result::Valid::Iterable::Array::Tuples.instance(:hash)
                Node::TestReducer.reduce(iterable, data, block).navigable
              end
            end

            module ValidHash
              def self.call(data, block)
                iterable = Result::Valid::Iterable::Hash.instance(:hash, {})
                Node::TestReducer.reduce(iterable, data, block).navigable
              end
            end
          end
        end
      end
    end
  end
end

N = 10_000

k = 3
puts "------------------------------- #{N}, #{k} -------------------------------"
Lite::Validation::Validator::Benchmark::Calibrational::Iteration.run(N, k)
k = 30
puts "------------------------------- #{N}, #{k} -------------------------------"
Lite::Validation::Validator::Benchmark::Calibrational::Iteration.run(N, k)
k = 300
puts "------------------------------- #{N}, #{k} -------------------------------"
Lite::Validation::Validator::Benchmark::Calibrational::Iteration.run(N, k)
