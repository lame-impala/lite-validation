# frozen_string_literal: true

require 'lite/data'
require_relative 'abstract/invalid'

module Lite
  module Validation
    module Validator
      module Ruling
        class Invalidate < Abstract::Invalid
          class Raw < Abstract::Invalid::Raw
            def dispute
              Ruling::Dispute(code, message: message, data: data)
            end

            def refute
              Ruling::Refute(code, message: message, data: data)
            end
          end

          def dispute
            Ruling::Dispute(error)
          end

          def refute
            Ruling::Refute(error)
          end
        end
      end
    end
  end
end
