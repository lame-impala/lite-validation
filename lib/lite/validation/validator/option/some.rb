# frozen_string_literal: true

require 'lite/data'

require_relative 'some/simple'
require_relative 'some/complex'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          def self.instance(value)
            Simple.new(value)
          end
        end
      end
    end
  end
end
