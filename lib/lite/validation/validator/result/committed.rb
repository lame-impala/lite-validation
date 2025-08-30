# frozen_string_literal: true

require_relative 'abstract/instance'
require_relative 'abstract/success'
require_relative '../option'

module Lite
  module Validation
    module Validator
      module Result
        class Committed < Abstract::Instance
          include Abstract::Success

          Lite::Data.define(self, args: %i[value])

          def self.instance(value, *args)
            new(value, *args)
          end

          private_class_method :new

          def success_at?(*_path)
            true
          end

          def committed?
            true
          end

          def refuted?
            false
          end

          def commit(*)
            prevent_reopening!
          end

          def auto_commit(as:)
            prevent_reopening!
          end

          def dispute(_error)
            prevent_reopening!
          end

          def refute(_error)
            prevent_reopening!
          end

          def navigate(*_path, &_block)
            prevent_reopening!
          end

          def success
            Option.some(value)
          end

          def inspect
            signature('Committed', "value=#{value}")
          end

          private

          def recurse(*_path, &_block)
            prevent_reopening!
          end

          def prevent_reopening!
            raise Error::Fatal, "Can't reopen committed result"
          end
        end
      end
    end
  end
end
