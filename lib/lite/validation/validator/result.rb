# frozen_string_literal: true

require_relative 'result/valid'

module Lite
  module Validation
    module Validator
      module Result
        def self.valid
          @valid ||= Valid::Navigable.instance
        end
      end
    end
  end
end
