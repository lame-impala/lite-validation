# frozen_string_literal: true

require_relative 'abstract/non_iterable'
require_relative '../../singular'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Wrappers
              class Object < Abstract::NonIterable
                include Singular

                def fetch(key)
                  Option.some(value.send(key))
                rescue StandardError => e
                  raise InvalidAccess, e.message
                end

                def inspect
                  "#<Option::Some::Object class=#{value.class.name}>"
                end

                Registry.register(::Object, self)
              end
            end
          end
        end
      end
    end
  end
end
