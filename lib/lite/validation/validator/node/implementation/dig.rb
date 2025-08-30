# frozen_string_literal: true

require_relative '../../helpers/path'
require_relative '../../option/some/complex/wrappers/abstract'
require_relative 'helpers/with_result'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Dig
            protected

            def dig(*path, from: nil, &block)
              from = Validator::Helpers::Path.expand_path(from || path, [])
              dig!(path, from, &block)
            end

            private

            def dig!(path, from, &block)
              updated, _meta = result.navigate(*path) do |local|
                option = self.option.dig(from)

                block.call(option, local)
              rescue Option::Some::Complex::Wrappers::Abstract::InvalidAccess => e
                local.refute(coordinator.internal_error(:invalid_access, message: e.message))
              end

              Helpers::WithResult.with_result(self, updated)
            end
          end
        end
      end
    end
  end
end
