# frozen_string_literal: true

require 'lite/data'

require_relative '../abstract'
require_relative '../../../error'
require_relative '../../../structured_error'

module Lite
  module Validation
    module Validator
      module Ruling
        module Abstract
          module Valid
            def invalid(&_block)
              self
            end
          end
        end
      end
    end
  end
end
