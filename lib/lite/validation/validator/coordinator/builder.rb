# frozen_string_literal: true

require_relative 'errors/builder'

require_relative 'default'
require_relative '../node/root'

module Lite
  module Validation
    module Validator
      module Coordinator
        class Builder
          include Ruling::Constructors

          def self.define(&block)
            new.tap { _1.instance_eval(&block) }.build
          end

          def initialize
            @validation_error_adapter = nil
            @final_error_adapter = nil
            @interface_adapter = nil
          end

          def validation_error_adapter(&block)
            if block
              raise(Error, 'Validation error adapter already set') unless @validation_error_adapter.nil?

              @validation_error_adapter = Errors::Builder.define(&block)

            else
              @validation_error_adapter
            end
          end

          def final_error_adapter(*args)
            case args.length
            when 1
              raise(Error, 'Final error adapter already set') unless @final_error_adapter.nil?

              @final_error_adapter = args[0]
            when 0
              @final_error_adapter
            else raise Error, "Unexpected arguments to builder: #{args.inspect}"
            end
          end

          def interface_adapter(*args)
            case args.length
            when 1
              raise(Error, 'Monads adapter already set') unless @interface_adapter.nil?

              @interface_adapter = args[0]

            when 0 then @interface_adapter
            else raise Error, "Unexpected arguments to builder: #{args.inspect}"
            end
          end

          def build
            result = validate
            raise Error, "Builder invalid: #{result.error.message}" unless result.success?

            Coordinator::Instance.new(
              interface: interface_adapter,
              validation_error: validation_error_adapter.build,
              final_error: final_error_adapter
            )
          end

          def validate # rubocop:disable Metrics/AbcSize
            coordinator = Coordinator::Default.instance(Errors::Flat)

            Validator::Node::Root.initial(self, coordinator).at do |builder|
              builder.validate(:interface_adapter) do |adapter|
                Refute(coordinator.internal_error(:value_missing)) if adapter.nil?
              end.validate(:final_error_adapter) do |adapter|
                Refute(coordinator.internal_error(:value_missing)) if adapter.nil?
              end.at(:validation_error_adapter) do |errors|
                errors.validate do |adapter|
                  Refute(coordinator.internal_error(:value_missing)) if adapter.nil?
                end.validate(:structured_error) do |proc|
                  Refute(coordinator.internal_error(:value_missing)) if proc.nil?
                end
              end
            end.to_result
          end
        end
      end
    end
  end
end
