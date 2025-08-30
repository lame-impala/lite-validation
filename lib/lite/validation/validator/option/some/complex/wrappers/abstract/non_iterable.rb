# frozen_string_literal: true

require_relative '../abstract'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Wrappers
              module Abstract
                class NonIterable < Some::Abstract
                  include Abstract

                  def iterable?
                    false
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
