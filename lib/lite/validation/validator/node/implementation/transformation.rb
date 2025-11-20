# frozen_string_literal: true

require_relative '../../ruling'
require_relative '../suspended'
require_relative 'dig'
require_relative 'helpers/call_foreign'
require_relative 'helpers/yield_strategy'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Transformation
            include Ruling::Constructors
            include Dig

            def commit_at?(*path, from: nil, &block)
              return Suspended.new(:commit_at!, self, path, from) if block.nil?

              commit_at!(path, from, :skip, block)
            end

            def commit_at(*path, from: nil, &block)
              commit_at!(path, from, :refute, block)
            end

            private

            def commit_at!(path, from, strategy, block)
              return self unless result.success?

              dig(*path, from: from) do |option, result|
                strategy = Helpers::YieldStrategy.to_yield(strategy)
                strategy.block_parameters(self, option, result) do |to_yield|
                  Helpers::CallForeign.call_foreign(result, coordinator) do
                    value = block.call(to_yield, context)
                    result.commit(value)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
