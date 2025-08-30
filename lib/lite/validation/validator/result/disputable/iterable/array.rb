# frozen_string_literal: true

require_relative '../iterable'

module Lite
  module Validation
    module Validator
      module Result
        module Disputable
          module Iterable
            module Array
              include Iterable

              def child(_key)
                Result.valid
              end
            end
          end
        end
      end
    end
  end
end
