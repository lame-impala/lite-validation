# frozen_string_literal: true

require_relative '../../unit/validator'
require_relative '../../unit/coordinators/dry'

module Lite
  module Validation
    module Validator
      RSpec.shared_context 'with fake validator' do
        let(:fake) do
          Node::Child::Leaf.instance(
            nil,
            [Node::Implementation::Identity.intent_id],
            Option.some('FOO'),
            Result.valid,
            Validator::State.initial(Support::Unit::Coordinators::Dry::Flat, context: { foo: 'BAR' })
          )
        end
      end
    end
  end
end
