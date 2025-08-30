# frozen_string_literal: true

require_relative 'dig'
require_relative 'helpers/yield_validator'
require_relative 'helpers/yield_strategy'
require_relative 'iteration/iterator'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Iteration
            include Dig

            def each_at?(*path, from: nil, commit: false, &block)
              each_at!(path, from, :skip, commit, block)
            end

            def each_at(*path, from: nil, commit: false, &block)
              each_at!(path, from, :refute, commit, block)
            end

            private

            def each_at!(path, from, strategy, commit, block)
              from = Validator::Helpers::Path.expand_path(from || path, [])
              return Iterator.new(self, path, from, strategy, commit) if block.nil?

              Iterator.iterate(self, path, from, strategy, commit) do |iterable, key, value, result, context|
                child = iterable.child(
                  [key],
                  result,
                  option: Option.some(value),
                  state: iterable.send(:state).with(context: context).value_definite
                )

                Helpers::YieldValidator.yield_child(iterable, child, block)
              end
            end
          end
        end
      end
    end
  end
end
