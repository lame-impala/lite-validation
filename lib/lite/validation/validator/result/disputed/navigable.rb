# frozen_string_literal: true

require_relative 'iterable'
require_relative '../disputable/navigable'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          class Navigable < Abstract::Hash
            include Disputable::Navigable

            def self.instance(*args, error: nil)
              instance = new([], EMPTY, *args)
              error ? instance.dispute(error) : instance
            end

            def initialize(errors, children, *args)
              super(errors.freeze, children.freeze, *args)
            end

            def commit(_value)
              self
            end

            def auto_commit(as:)
              self
            end

            def dispute(error)
              raise Error::Fatal, "Structured error expected, got: #{error.inspect}" unless error.is_a?(StructuredError)

              self.class.send :new, [*errors_root, error], children
            end

            def inspect
              signature('Disputed::Navigable')
            end

            def iterable(commit:)
              Iterable::Hash.instance(errors_root, children)
            end

            def merge(result, key)
              return self if result.success?

              self.class.send(
                :new,
                errors_root,
                children.merge(key => result)
              )
            end
          end
        end
      end
    end
  end
end
