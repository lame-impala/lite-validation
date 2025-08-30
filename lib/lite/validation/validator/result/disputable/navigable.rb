# frozen_string_literal: true

require_relative 'hash'

module Lite
  module Validation
    module Validator
      module Result
        module Disputable
          module Navigable
            include Hash

            def success_at?(*path)
              if path.empty?
                success?
              else
                key, *rest = path
                child(key).success_at?(*rest)
              end
            end

            def navigate(*path, &block)
              if path.empty?
                block.call(self)
              else
                key, *rest = path
                enter(key, *rest, &block)
              end
            end
          end
        end
      end
    end
  end
end
