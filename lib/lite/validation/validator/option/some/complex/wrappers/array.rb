# frozen_string_literal: true

require_relative 'abstract/iterable'
require_relative '../../singular'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Wrappers
              class Array < Abstract::Iterable
                include Singular

                def fetch(index)
                  raise InvalidAccess, "Invalid index to array: #{index}" unless index.is_a?(Integer)
                  return Option.none unless (0...value.length).include?(index)

                  Option.some(value[index])
                end

                def reduce(initial_state, &block)
                  value.lazy
                       .each_with_index
                       .reduce(initial_state, &block)
                end

                def inspect
                  "#<Option::Some::Array length=#{value.length}>"
                end

                Registry.register(::Array, self)
              end
            end
          end
        end
      end
    end
  end
end
