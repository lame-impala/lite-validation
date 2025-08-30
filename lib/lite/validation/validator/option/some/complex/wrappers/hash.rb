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
              class Hash < Abstract::Iterable
                include Singular

                def fetch(key)
                  return Option.none unless value.key? key

                  Option.some(value[key])
                end

                def reduce(initial_state, &block)
                  value.lazy
                       .map { |key, value| [value, key] }
                       .reduce(initial_state, &block)
                end

                def inspect
                  "#<Option::Some::Hash length=#{value.length}>"
                end

                Registry.register(::Hash, self)
              end
            end
          end
        end
      end
    end
  end
end
