# frozen_string_literal: true

module Lite
  module Validation
    module Result
      module Abstract
        module Success
          def failure?
            false
          end

          def to_result(coordinator)
            coordinator.success(success)
          end

          private

          def success
            raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
          end
        end
      end
    end
  end
end
