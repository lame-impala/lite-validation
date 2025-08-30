# frozen_string_literal: true

require_relative '../../../error'

module Lite
  module Validation
    module Validator
      module Predicate
        module Abstract
          module Variants
            def definite
              raise Error::Fatal, 'Definite variant not available'
            end

            def optional
              raise Error::Fatal, 'Optional variant not available'
            end
          end
        end
      end
    end
  end
end
