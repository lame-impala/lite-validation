# frozen_string_literal: true

require 'dry-monads'

module Lite
  module Validation
    module Adapters
      module Interfaces
        module Dry
          def success(value)
            ::Dry::Monads::Result::Success.new(value)
          end

          def failure(error)
            ::Dry::Monads::Result::Failure.new(error)
          end

          def some(value)
            ::Dry::Monads::Result::Success.new(value)
          end

          def none
            ::Dry::Monads::Result::Failure.new(::Dry::Monads::Unit)
          end
        end
      end
    end
  end
end
