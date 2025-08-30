# frozen_string_literal: true

require_relative '../helpers/yield_strategy'
require_relative '../helpers/yield_validator'
require_relative '../validation'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Iteration
            class Iterator
              def self.iterate(node, path, from, strategy, commit, &block)
                node.send(:dig!, path, from) do |option, result|
                  Helpers::YieldStrategy
                    .to_iterate(strategy)
                    .maybe_yield(node, option, result) do
                    complex = option.to_complex
                    next result.refute(node.coordinator.internal_error(:not_iterable)) unless complex.iterable?

                    iterable = node.child(path, result.iterable(commit: commit), option: complex)
                    updated, meta = reduce(iterable, block)

                    [node.merge_strategy.transform_result(updated.navigable, node, path), meta]
                  end
                end
              end

              def self.reduce(iterable, block)
                iterable.send(:option).reduce([iterable.result, iterable.context]) do |(result, context), (value, key)|
                  break [result, context] if result.refuted?

                  result.navigate(key) do |key_result|
                    block.call(iterable, key, value, key_result, context)
                  end
                end
              end

              def initialize(parent, path, from, strategy, commit)
                @parent = parent
                @path = path
                @from = from
                @strategy = strategy
                @commit = commit
                freeze
              end

              def validate(commit: false, &block)
                self.class.iterate(
                  parent,
                  path,
                  from,
                  strategy,
                  self.commit
                ) do |iterable, _key, value, result, context|
                  updated = Validation.validate(
                    iterable.coordinator,
                    value,
                    result,
                    context,
                    commit,
                    block
                  )
                  [updated, context]
                end
              end

              def satisfy(using: nil, severity: :dispute, commit: false, &block)
                predicate = Predication
                            .resolve_predicate(using, from, parent.context, block)
                            .definite
                            .send(severity)

                self.class.iterate(
                  parent,
                  path,
                  from,
                  strategy,
                  self.commit
                ) do |iterable, _key, value, result, context|
                  Validation.validate(
                    iterable.coordinator,
                    value,
                    result,
                    context,
                    commit,
                    predicate
                  )
                end
              end

              private

              attr_reader :parent, :path, :from, :strategy, :commit
            end
          end
        end
      end
    end
  end
end
