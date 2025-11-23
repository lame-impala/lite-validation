# frozen_string_literal: true

require_relative '../../../../error'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Helpers
            module YieldStrategy
              module Skip
                def self.child_parameters(validator, option, result, &block)
                  maybe_yield(nil, option, result) { block.call(option, validator.send(:state).value_definite) }
                end

                def self.block_parameters(_validator, option, result, &block)
                  maybe_yield(nil, option, result) { block.call(option.unwrap) }
                end

                def self.maybe_yield(_, option, result, &block)
                  option.some? ? block.call : result
                end
              end

              module Nullify
                def self.child_parameters(validator, option, _result, &block)
                  block.call(option.some_or_nil, validator.send(:state).value_definite)
                end

                def self.block_parameters(_validator, option, _result, &block)
                  block.call(option.some_or_nil.unwrap)
                end
              end

              module Refute
                def self.child_parameters(validator, option, result, &block)
                  maybe_yield(validator, option, result) { block.call(option, validator.send(:state).value_definite) }
                end

                def self.block_parameters(validator, option, result, &block)
                  maybe_yield(validator, option, result) { block.call(option.unwrap) }
                end

                def self.maybe_yield(validator, option, result, &block)
                  option.some? ? block.call : result.refute(validator.coordinator.internal_error(:value_missing))
                end
              end

              module YieldOption
                def self.child_parameters(validator, option, _result, &block)
                  block.call(option, validator.send(:state).value_optional)
                end

                def self.block_parameters(validator, option, _result, &block)
                  block.call(option.to_option(validator.coordinator))
                end
              end

              def self.to_yield(strategy)
                case strategy
                when :skip then Skip
                when :nullify then Nullify
                when :refute then Refute
                when :yield_option then YieldOption
                else raise Error::Fatal, "Unexpected missing yield strategy: #{strategy}"
                end
              end

              def self.to_iterate(strategy)
                case strategy
                when :skip then Skip
                when :refute then Refute
                else raise Error::Fatal, "Unexpected missing iteration strategy: #{strategy}"
                end
              end
            end
          end
        end
      end
    end
  end
end
