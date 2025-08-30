# frozen_string_literal: true

require_relative '../../result'
require_relative '../../option'

module Lite
  module Validation
    module Validator
      module Adapters
        module Interfaces
          module Default
            def self.success(value)
              Result::Committed.instance(value)
            end

            def self.failure(error)
              Result::Refuted.instance(error)
            end

            def self.some(value)
              Option.some(value)
            end

            def self.none
              Option.none
            end
          end
        end
      end
    end
  end
end
