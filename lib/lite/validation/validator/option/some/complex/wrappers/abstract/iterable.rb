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
                class Iterable < Some::Abstract
                  include Abstract

                  def iterable?
                    true
                  end

                  def reduce
                    raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
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
