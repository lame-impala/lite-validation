# frozen_string_literal: true

require_relative 'helpers/call_foreign'
require_relative 'helpers/yield_validator'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Wrap
            private

            def wrap(**opts, &block)
              Helpers::CallForeign.call_foreign(result, coordinator) do
                proxy = opts.empty? ? self : child(nil, result, **opts)

                Helpers::YieldValidator.ensure_valid_result!(proxy, block.call(proxy)).result
              end
            end
          end
        end
      end
    end
  end
end
