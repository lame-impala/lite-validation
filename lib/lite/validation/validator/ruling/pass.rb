# frozen_string_literal: true

require_relative 'abstract/valid'

module Lite
  module Validation
    module Validator
      module Ruling
        class Pass
          extend Abstract::Valid

          def self.===(other)
            equal?(other)
          end
        end
      end
    end
  end
end
