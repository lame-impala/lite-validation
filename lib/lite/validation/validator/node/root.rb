# frozen_string_literal: true

require_relative '../result'
require_relative '../state'
require_relative '../option'

require_relative 'abstract/instance'
require_relative 'abstract/leaf'
require_relative 'abstract/branch'
require_relative 'child'

module Lite
  module Validation
    module Validator
      module Node
        module Root
          include Child::Parent

          def self.initial(bare_value, coordinator, context: nil)
            Leaf.instance(
              nil,
              [Node::Implementation::Identity.intent_id],
              Option.some(bare_value),
              Result.valid,
              State.initial(coordinator, context: context)
            )
          end

          def to_result(coordinator: self.coordinator)
            result.success? ? to_success(coordinator) : to_failure(coordinator)
          end

          def inspect
            "#<Root::#{super}"
          end

          private

          def to_success(coordinator)
            coordinator.success(result.success.some? ? result.success.value : option.value)
          end

          def to_failure(coordinator)
            coordinator.failure(result.to_failure(coordinator))
          end

          class Leaf < Abstract::Instance
            include Abstract::Leaf
            include Root
          end

          class Branch < Abstract::Instance
            include Abstract::Branch
            include Root
          end
        end
      end
    end
  end
end
