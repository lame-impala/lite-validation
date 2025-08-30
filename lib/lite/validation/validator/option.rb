# frozen_string_literal: true

require_relative 'option/some'
require_relative 'option/none'

module Lite
  module Validation
    module Validator
      module Option
        def self.some(value)
          Some.instance(value)
        end

        def self.none
          None
        end
      end
    end
  end
end
