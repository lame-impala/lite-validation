# frozen_string_literal: true

require_relative '../../../../error'
require_relative 'input/single'
require_relative 'input/tuple'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          module Adapter
            module Input
              def self.instance(arity)
                raise Error::Fatal, "Arity must be positive integer, got: #{arity}" unless arity.positive?

                case arity
                when 1 then Single
                else Tuple
                end
              end
            end
          end
        end
      end
    end
  end
end
