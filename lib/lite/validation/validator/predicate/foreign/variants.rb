# frozen_string_literal: true

require_relative '../abstract/variants'
require_relative 'variant'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          class Variants
            include Abstract::Variants

            Lite::Data.define(self, kwargs: %i[definite optional])

            def initialize(definite: nil, optional: nil)
              super
            end

            def definite
              @definite || super
            end

            def optional
              @optional || super
            end

            def dispute
              with definite: definite&.dispute, optional: optional&.dispute
            end

            def refute
              with definite: definite&.refute, optional: optional&.refute
            end

            def with(definite: self.definite, optional: self.optional)
              return self if definite == self.definite && optional == self.optional

              super
            end
          end
        end
      end
    end
  end
end
