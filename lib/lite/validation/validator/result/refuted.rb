# frozen_string_literal: true

require_relative 'abstract/instance'
require_relative 'abstract/failure'

module Lite
  module Validation
    module Validator
      module Result
        class Refuted < Abstract::Instance
          include Abstract::Failure

          Lite::Data.define(self, args: %i[error], kwargs: [:fall_through])

          def self.instance(error, *args, fall_through: false)
            raise Error::Fatal, "Structured error expected, got: #{error.inspect}" unless error.is_a?(StructuredError)

            new(error, *args, fall_through: fall_through)
          end

          private_class_method :new

          def success_at?(*_path)
            false
          end

          def committed?
            false
          end

          def refuted?
            true
          end

          def commit(_value)
            self
          end

          def auto_commit(as:)
            self
          end

          def dispute(error)
            raise Error, "Structured error expected, got: #{error.inspect}" unless error.is_a?(StructuredError)

            self
          end

          def refute(error)
            raise Error::Fatal, "Structured error expected, got: #{error.inspect}" unless error.is_a?(StructuredError)

            self
          end

          def navigable
            self
          end

          def navigate(*_path, &_block)
            self
          end

          def errors_root
            [error]
          end

          def children
            EMPTY
          end

          def inspect
            signature('Refuted', "error=#{error.code}")
          end
        end
      end
    end
  end
end
