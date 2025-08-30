# frozen_string_literal: true

require 'lite/data'

require_relative 'unwrap_strategy'
require_relative 'merge_strategy'

module Lite
  module Validation
    module Validator
      module State
        class Instance
          Lite::Data.define(self, args: [:coordinator], kwargs: %i[context merge_strategy unwrap_strategy])

          def value_definite
            return self if unwrap_strategy == UnwrapStrategy::Value

            with(unwrap_strategy: UnwrapStrategy::Value)
          end

          def value_optional
            return self if unwrap_strategy == UnwrapStrategy::Option

            with(unwrap_strategy: UnwrapStrategy::Option)
          end

          def critical(section_start, error_generator)
            merge_strategy = MergeStrategy::Critical.new(section_start, error_generator)

            with(merge_strategy: merge_strategy)
          end

          def non_critical
            return self if merge_strategy == MergeStrategy::Standard

            with(merge_strategy: MergeStrategy::Standard)
          end

          def inspect
            "#<State context=#{context.inspect} merge=#{merge_strategy.inspect} unwrap=#{unwrap_strategy.inspect}"
          end
        end
      end
    end
  end
end
