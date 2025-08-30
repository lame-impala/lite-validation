# frozen_string_literal: true

require_relative 'instance'

module Lite
  module Validation
    module Validator
      module Predicate
        module Native
          class Definite < Instance
            def definite
              self
            end
          end
        end
      end
    end
  end
end
