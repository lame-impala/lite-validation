# frozen_string_literal: true

require 'lite/data'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          class Variant
            Lite::Data.define(self, args: %i[callable adapter])

            def call(value, _context)
              adapter.to_ruling(adapter.pass_in(value, callable), callable, value)
            end

            def severity
              adapter.severity
            end

            def dispute
              severity == :dispute ? self : with(adapter: adapter.dispute)
            end

            def refute
              severity == :refute ? self : with(adapter: adapter.refute)
            end
          end
        end
      end
    end
  end
end
