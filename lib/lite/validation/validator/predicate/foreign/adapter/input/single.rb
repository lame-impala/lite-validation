# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          module Adapter
            module Input
              module Single
                def self.pass_in(value, block)
                  block.call(value)
                end
              end
            end
          end
        end
      end
    end
  end
end
