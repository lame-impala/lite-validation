# frozen_string_literal: true

require_relative '../abstract/instance'
require_relative '../refuted'

module Lite
  module Validation
    module Validator
      module Result
        module Disputable
          class Instance < Abstract::Instance
            Lite::Data.define(self, args: %i[children])

            private_class_method :new

            def committed?
              false
            end

            def refuted?
              false
            end

            def refute(error, fall_through: false)
              Refuted.instance(error, fall_through: fall_through)
            end

            private

            def enter(key, *rest, &block)
              child = child(key)
              result, meta = child.navigate(*rest, &block)
              return [self, meta] if child.equal?(result)
              return [result, meta] if result.refuted? && result.fall_through

              [merge(result, key), meta]
            end
          end
        end
      end
    end
  end
end
