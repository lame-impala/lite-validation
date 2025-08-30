# frozen_string_literal: true

require_relative '../abstract'

module Lite
  module Validation
    module Result
      module Abstract
        module Disputable
          def dispute(_error)
            raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
          end
        end
      end
    end
  end
end
