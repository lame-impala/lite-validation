# frozen_string_literal: true

require_relative '../abstract'

module Lite
  module Validation
    module Validator
      module Result
        module Abstract
          module Failure
            include Validation::Result::Abstract::Failure

            def to_failure(coordinator)
              coordinator.build_final_error(self)
            end
          end
        end
      end
    end
  end
end
