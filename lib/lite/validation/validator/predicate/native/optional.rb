# frozen_string_literal: true

require_relative 'instance'
require_relative '../../ruling'

module Lite
  module Validation
    module Validator
      module Predicate
        module Native
          class Optional < Instance
            Lite::Data.define(self, kwargs: [:definite])

            def optional
              self
            end

            def dispute
              with(severity: :dispute, definite: definite&.dispute)
            end

            def refute
              with(severity: :refute, definite: definite&.refute)
            end

            def validate_value(value)
              definite.call(value)
            end
          end
        end
      end
    end
  end
end
