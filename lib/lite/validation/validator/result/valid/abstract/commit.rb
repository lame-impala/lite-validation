# frozen_string_literal: true

require_relative '../../committed'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Abstract
            module Commit
              def commit(value)
                Committed.instance(value)
              end

              def unexpected_option!(option)
                raise Error, "Unexpected option: #{option}"
              end
            end
          end
        end
      end
    end
  end
end
