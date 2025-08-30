# frozen_string_literal: true

require_relative '../abstract'

module Lite
  module Validation
    module Validator
      module Node
        module Abstract
          module Leaf
            include Abstract

            def branch
              self.class::Branch.instance parent, path, option.to_complex, result, state
            end

            def inspect
              "Leaf #{super}"
            end

            private

            def dig(*path, from: nil, &block)
              if path.empty?
                super
              else
                branch.dig(*path, from: from, &block)
              end
            end
          end
        end
      end
    end
  end
end
