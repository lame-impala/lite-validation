# frozen_string_literal: true

require_relative 'helpers/yield_validator'
require_relative 'scoping/evaluator'
require_relative 'dig'
require_relative 'wrap'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Scoping
            include Dig
            include Wrap

            def critical(error_generator, &block)
              dig do |_option, result|
                child = child(nil, result, state: state.critical(self, error_generator))
                updated, _meta = Helpers::YieldValidator.yield_validator(child, block)
                updated.refuted? ? updated.with(fall_through: false) : updated
              end
            end

            def with_context(context, &block)
              if block
                result, _meta = wrap(state: state.with(context: context), &block)
                Helpers::WithResult.with_result(self, result)
              else
                with(state: state.with(context: context))
              end
            end

            def with_valid(*path, &block)
              with_valid = Evaluator.instance(self, path)
              block.nil? ? with_valid : with_valid.call(&block)
            end
          end
        end
      end
    end
  end
end
