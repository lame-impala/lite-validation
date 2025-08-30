# frozen_string_literal: true

require_relative '../abstract/instance'
require_relative '../../disputable/hash'
require_relative '../../disputable/iterable'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Iterable
            class Hash < Valid::Abstract::Instance
              include Disputable::Hash
              include Disputable::Iterable

              Lite::Data.define(self, args: %i[commit_as])

              def self.instance(commit, children)
                new(commit, children.dup)
              end

              def inspect
                signature('Valid::Iterable::Hash', nil)
              end

              def navigable
                navigable = Valid.navigable(children)
                commit_as ? navigable.auto_commit(as: commit_as) : navigable
              end

              def merge(result, key)
                if result.success?
                  children.merge!(key => result) if commit_as == false || result.committed?
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
