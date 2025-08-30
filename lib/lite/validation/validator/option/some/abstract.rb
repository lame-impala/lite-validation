# frozen_string_literal: true

require 'lite/data'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          class Abstract
            Lite::Data.define(self, args: %i[value])

            def some?
              true
            end

            def none?
              false
            end

            def inspect
              "#<Option::Some value of #{value.class.name}>"
            end
          end
        end
      end
    end
  end
end
