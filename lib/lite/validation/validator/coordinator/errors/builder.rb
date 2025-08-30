# frozen_string_literal: true

require_relative '../../../error'
require_relative 'dry'
require_relative 'flat'
require_relative 'hierarchical'

module Lite
  module Validation
    module Validator
      module Coordinator
        module Errors
          class Builder
            def self.define(&block)
              new.tap { _1.instance_eval(&block) }
            end

            def initialize
              @internal_error = nil
              @structured_error = nil
            end

            def build
              builder = self

              Module.new do
                define_singleton_method :internal_error, &builder.internal_error || builder.structured_error
                define_singleton_method :structured_error, &builder.structured_error
              end
            end

            def internal_error(&block)
              if block
                raise(Error, 'Internal error proc already set') unless @internal_error.nil?

                @internal_error = block
              else
                @internal_error
              end
            end

            def structured_error(&block)
              if block
                raise(Error, 'Structured error proc already set') unless @structured_error.nil?

                @structured_error = block
              else
                @structured_error
              end
            end
          end
        end
      end
    end
  end
end
