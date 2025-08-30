# frozen_string_literal: true

require_relative 'abstract'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Iterable
            module Array
              class Tuples < Valid::Abstract::Instance
                include Abstract

                Lite::Data.define(self, args: %i[commit_as])

                def self.instance(commit, *args)
                  new(commit, [], *args)
                end

                def inspect
                  signature('Valid::Iterable::Array::Tuples', nil)
                end

                def navigable
                  case commit_as
                  when false then Valid.navigable(children.to_h.freeze)
                  when :hash then commit(children.to_h.freeze)
                  else unexpected_option!(commit_as)
                  end
                end

                def child(_key)
                  Result.valid
                end

                def merge(result, key)
                  if result.failure?
                    Disputed::Iterable.initial.append(result, key)
                  else
                    merge_success(result, key)
                    self
                  end
                end

                private

                def merge_success(result, key)
                  case commit_as
                  when false
                    children << [key, result]
                  when :hash
                    children << [key, result.value] if result.committed?
                  else unexpected_option!(commit_as)
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
