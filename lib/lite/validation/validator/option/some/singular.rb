# frozen_string_literal: true

require_relative 'dig'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Singular
            include Dig

            def some_or_nil
              self
            end

            def to_option(coordinator)
              coordinator.some(value)
            end

            def unwrap
              value
            end
          end
        end
      end
    end
  end
end
