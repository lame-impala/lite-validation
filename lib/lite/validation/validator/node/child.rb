# frozen_string_literal: true

require_relative 'abstract/instance'
require_relative 'abstract/leaf'
require_relative 'abstract/branch'
require_relative '../result'
require_relative '../state'
require_relative '../option'

module Lite
  module Validation
    module Validator
      module Node
        module Child
          module Parent
            def child(path, result, option: self.option, state: self.state)
              if path.nil? || path.empty?
                self.class::Leaf.instance(parent, self.path, option, result, state)
              else
                Child::Leaf.instance(self, path, option, result, state)
              end
            end
          end

          include Parent

          def inspect
            "#<Child::#{super}"
          end

          class Leaf < Abstract::Instance
            include Abstract::Leaf
            include Child
          end

          class Branch < Abstract::Instance
            include Abstract::Branch
            include Child
          end
        end
      end
    end
  end
end
