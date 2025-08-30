# frozen_string_literal: true

require_relative 'disputed/navigable'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          def self.navigable(errors, children)
            Disputed::Navigable.send(:new, errors, children)
          end
        end
      end
    end
  end
end
