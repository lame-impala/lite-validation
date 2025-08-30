# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module State
        module UnwrapStrategy
          module Value
            def self.unwrap(option, _coordinator)
              option.unwrap
            end

            def self.inspect
              '#<UnwrapStrategy::Value>'
            end
          end

          module Option
            def self.unwrap(option, coordinator)
              option.to_option(coordinator)
            end

            def self.inspect
              '#<UnwrapStrategy::Option>'
            end
          end
        end
      end
    end
  end
end
