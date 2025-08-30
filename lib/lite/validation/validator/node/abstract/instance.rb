# frozen_string_literal: true

require 'lite/data'

module Lite
  module Validation
    module Validator
      module Node
        module Abstract
          class Instance
            Lite::Data.define(self, args: %i[parent path option result state])

            def self.instance(parent, path, option, result, state)
              new(parent, path.freeze, option, result, state)
            end

            def coordinator
              state.coordinator
            end

            def value
              state.unwrap_strategy.unwrap(option, coordinator)
            end

            def merge_strategy
              state.merge_strategy
            end

            def context
              state.context
            end

            def inspect
              "#{display_path(true)} result=#{result.inspect} option=#{option.inspect} state=#{state.inspect}"
            end

            private :option, :state, :with
          end
        end
      end
    end
  end
end
