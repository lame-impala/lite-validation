# frozen_string_literal: true

require_relative 'abstract/non_iterable'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Wrappers
              class Tuple < Abstract::NonIterable
                def some_or_nil
                  return self if some?

                  self.class.new(value.map(&:some_or_nil))
                end

                def to_option(coordinator)
                  value.map { _1.to_option(coordinator) }
                end

                def unwrap
                  transpose.unwrap
                end

                def transpose
                  return Option.none unless some?

                  Option.some(value.map(&:value))
                end

                def some?
                  value.all?(&:some?)
                end

                def inspect
                  "#<Option::Some::Tuple (#{value.map(&:inspect).join(', ')})>"
                end
              end
            end
          end
        end
      end
    end
  end
end
