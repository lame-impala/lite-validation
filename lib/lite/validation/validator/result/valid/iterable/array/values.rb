# frozen_string_literal: true

require_relative 'abstract'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Iterable
            module Array
              class Values < Valid::Abstract::Instance
                include Abstract

                def self.instance(*args)
                  new([], *args)
                end

                def inspect
                  signature('Valid::Iterable::Array::Values', nil)
                end

                def navigable
                  commit(children.freeze)
                end

                def merge(result, key)
                  if result.success?
                    children << result.value if result.committed?
                    self
                  else
                    Disputed::Iterable.initial.append(result, key)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
