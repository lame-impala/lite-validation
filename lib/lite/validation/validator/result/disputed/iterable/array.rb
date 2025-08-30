# frozen_string_literal: true

require_relative '../abstract/instance'
require_relative '../../disputable/iterable/array'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          module Iterable
            class Array < Abstract::Instance
              include Disputable::Iterable::Array

              def self.instance(*args)
                new([], *args)
              end

              def inspect
                signature('Disputed::Iterable::Array')
              end

              def navigable
                Disputed.navigable([], children.to_h)
              end

              def signature(class_name)
                super(class_name, " with #{children.count} children")
              end

              def merge(result, key)
                children << [key, result] unless result.success?

                self
              end
            end
          end
        end
      end
    end
  end
end
