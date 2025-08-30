# frozen_string_literal: true

require_relative '../abstract'

module Lite
  module Validation
    module Result
      module Abstract
        module Refutable
          def refute(_error)
            raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
          end

          def refuted?
            raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
          end
        end
      end
    end
  end
end
