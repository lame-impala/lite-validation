# frozen_string_literal: true

module Lite
  module Validation
    module Result
      module Abstract
        module Failure
          def failure?
            true
          end

          def to_result(coordinator)
            coordinator.failure(coordinator.build_final_error(self))
          end
        end
      end
    end
  end
end
