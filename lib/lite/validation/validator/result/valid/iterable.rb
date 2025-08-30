# frozen_string_literal: true

require_relative 'iterable/array/tuples'
require_relative 'iterable/array/values'
require_relative 'iterable/hash'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Iterable
            def self.instance(children, commit:)
              if children.empty?
                initial(commit: commit)
              else
                Hash.instance(commit, children)
              end
            end

            def self.initial(commit:)
              case commit
              when :hash, false then Array::Tuples.instance(commit)
              when :array then Array::Values.instance
              else raise Error, "Unexpected option: #{commit}"
              end
            end
          end
        end
      end
    end
  end
end
