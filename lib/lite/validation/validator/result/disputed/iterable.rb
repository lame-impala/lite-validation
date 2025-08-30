# frozen_string_literal: true

require_relative 'iterable/array'
require_relative 'iterable/hash'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          module Iterable
            def self.initial
              Array.instance
            end
          end
        end
      end
    end
  end
end
