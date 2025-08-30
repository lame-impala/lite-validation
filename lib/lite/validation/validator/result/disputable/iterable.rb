# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Result
        module Disputable
          module Iterable
            def navigate(key, &block)
              enter(key, &block)
            end
          end
        end
      end
    end
  end
end
