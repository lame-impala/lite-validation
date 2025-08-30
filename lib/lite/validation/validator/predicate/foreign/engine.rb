# frozen_string_literal: true

require_relative 'variants'
require_relative '../registry'
require_relative '../../ruling'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          class Engine
            Lite::Data.define(self, args: [:error_adapter])

            def build(_keys, &_block)
              raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
            end

            def build_contextual(_keys, _context, &_block)
              raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
            end
          end
        end
      end
    end
  end
end
