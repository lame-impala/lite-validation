# frozen_string_literal: true

require 'lite/data'

require_relative '../abstract'
require_relative '../../../error'
require_relative '../../../structured_error'

module Lite
  module Validation
    module Validator
      module Ruling
        module Abstract
          class Invalid
            module Abstract
              include Ruling::Abstract

              def invalid(&block)
                block.call(self)
              end
            end

            class Raw
              include Abstract

              Lite::Data.define(self, args: %i[code message data])

              def self.instance(code, message: nil, data: nil)
                new code, message, data
              end

              def structured_error(coordinator)
                coordinator.structured_error(code, message: message, data: data)
              end
            end

            include Abstract

            Lite::Data.define(self, args: [:error])

            def self.instance(error, **opts)
              case [error, opts]
              in [StructuredError, {}] then new error
              in [Symbol, { ** }] then self::Raw.instance(error, **opts)
              else raise Error::Fatal, "Unexpected first argument: #{error.inspect}"
              end
            end

            private_class_method :new

            def structured_error(*)
              error
            end
          end
        end
      end
    end
  end
end
