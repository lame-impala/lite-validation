# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Option
        module None
          def self.some?
            false
          end

          def self.none?
            true
          end

          def self.dig(*_path)
            self
          end

          def self.to_complex
            self
          end

          def self.some_or_nil
            Option.some(nil)
          end

          def self.to_option(coordinator)
            coordinator.none
          end

          def self.iterable?
            false
          end

          def self.inspect
            '#<Option::None>'
          end
        end
      end
    end
  end
end
