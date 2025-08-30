# frozen_string_literal: true

require_relative 'state/merge_strategy'
require_relative 'state/instance'

module Lite
  module Validation
    module Validator
      module State
        def self.initial(coordinator, context: nil)
          Instance.new(
            coordinator,
            context: context,
            merge_strategy: MergeStrategy::Standard,
            unwrap_strategy: UnwrapStrategy::Value
          )
        end
      end
    end
  end
end
