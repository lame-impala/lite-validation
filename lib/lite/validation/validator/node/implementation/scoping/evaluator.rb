# frozen_string_literal: true

require_relative '../helpers/with_result'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Scoping
            class Evaluator
              def self.instance(validator, path)
                new(validator, [path].freeze)
              end

              private_class_method :new

              def initialize(validator, paths)
                @validator = validator
                @paths = paths
              end

              def and(path, &block)
                compound = self.class.send(:new, validator, [*paths, path])
                return compound if block.nil?

                compound.call(&block)
              end

              attr_reader :validator, :paths

              def call(&block)
                return validator unless paths.all? { validator.result.success_at?(*_1) }

                Helpers::WithResult.with_result(validator, validator.send(:wrap, &block))
              end
            end
          end
        end
      end
    end
  end
end
