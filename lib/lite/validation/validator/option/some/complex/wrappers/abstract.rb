# frozen_string_literal: true

require_relative '../../../../../error'
require_relative '../../abstract'
require_relative '../registry'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Wrappers
              module Abstract
                class InvalidAccess < Error::Fatal; end

                def fetch(_key)
                  raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
                end

                def iterable?
                  raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
                end

                def to_complex
                  self
                end
              end
            end
          end
        end
      end
    end
  end
end
