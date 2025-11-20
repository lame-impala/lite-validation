# frozen_string_literal: true

require_relative 'dig'
require_relative '../suspended'
require_relative 'helpers/yield_validator'
require_relative 'helpers/yield_strategy'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Navigation
            include Dig

            def at?(*path, from: nil, &block)
              return Suspended.new(:at!, self, path, from) if block.nil?

              at!(path, from, :skip, block)
            end

            def at(*path, from: nil, &block)
              at!(path, from, :refute, block)
            end

            private

            def at!(path, from, strategy, block)
              dig(*path, from: from) do |option, result|
                strategy = Helpers::YieldStrategy.to_yield(strategy)
                strategy.child_parameters(self, option, result) do |to_yield, child_state|
                  child = child(path, result, option: to_yield, state: child_state)

                  Helpers::YieldValidator.yield_child(self, child, block)
                end
              end
            end
          end
        end
      end
    end
  end
end
