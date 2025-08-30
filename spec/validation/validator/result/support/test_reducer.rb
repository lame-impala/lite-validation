# frozen_string_literal: true

require_relative '../../support/unit/coordinators/dry'
require_relative '../../../../../lib/lite/validation/validator/node/root'

module Lite
  module Validation
    module Validator
      module Node
        module TestReducer
          def self.reduce(iterable, data, block)
            result, _meta = Implementation::Iteration::Iterator
                            .reduce(initial(iterable, data), block)

            result
          end

          def self.initial(iterable, data)
            Node::Root::Leaf.instance(
              nil,
              [Node::Implementation::Identity.intent_id],
              Option.some(data).to_complex,
              iterable,
              State.initial(Support::Unit::Coordinators::Dry::Hierarchical, context: nil)
            )
          end
        end
      end
    end
  end
end
