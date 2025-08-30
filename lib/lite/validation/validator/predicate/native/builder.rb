# frozen_string_literal: true

require_relative 'definite'
require_relative 'optional'

require_relative '../../coordinator/default'
require_relative '../../node/root'
require_relative '../../coordinator/errors/flat'

module Lite
  module Validation
    module Validator
      module Predicate
        module Native
          class Builder
            include Ruling::Constructors

            def initialize
              @validate_value = nil
              @validate_option = nil
            end

            def self.define(&block)
              new.tap { _1.instance_eval(&block) }.build
            end

            def validate_value(&block)
              if block
                raise(Error, 'Test value already set') unless @validate_value.nil?

                @validate_value = block

              else
                @validate_value
              end
            end

            def validate_option(&block)
              if block
                raise(Error, 'Test option already set') unless @validate_option.nil?

                @validate_option = block
              else
                @validate_option
              end
            end

            def build
              result = validate
              raise Error, "Builder invalid: #{result.error.message}" unless result.success?

              definite = validate_value ? Native::Definite.new(validate_value) : nil
              return definite if validate_option.nil?

              Native::Optional.new(validate_option, definite: definite)
            end

            def validate
              coordinator = Coordinator::Default.instance(Coordinator::Errors::Flat)

              Validator::Node::Root.initial(self, coordinator).at do |builder|
                builder.validate(%i[validate_option validate_value]) do |tuple|
                  Refute(coordinator.internal_error(:value_missing)) if tuple.all?(&:nil?)
                end
              end.to_result
            end
          end
        end
      end
    end
  end
end
