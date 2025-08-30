# frozen_string_literal: true

require_relative '../abstract/hash'
require_relative '../../disputable/iterable'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          module Iterable
            class Hash < Abstract::Hash
              include Disputable::Iterable

              def self.instance(errors, children)
                new(errors.dup, children.dup)
              end

              def inspect
                signature('Disputed::Iterable::Hash')
              end

              def navigable
                Disputed.navigable(errors_root, children)
              end

              def merge(result, key)
                children.merge!(key => result) unless result.success?

                self
              end
            end
          end
        end
      end
    end
  end
end
