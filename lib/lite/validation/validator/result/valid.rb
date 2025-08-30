# frozen_string_literal: true

require_relative 'abstract/success'
require_relative 'valid/navigable'
require_relative 'committed'
require_relative 'disputed'
require_relative '../option'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          def self.navigable(children)
            Valid::Navigable.send(:new, children)
          end
        end
      end
    end
  end
end
