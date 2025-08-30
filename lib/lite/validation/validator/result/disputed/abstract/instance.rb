# frozen_string_literal: true

require_relative '../../abstract/failure'
require_relative '../../disputable/instance'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          module Abstract
            class Instance < Disputable::Instance
              include Result::Abstract::Failure

              def append(result, key)
                raise Error::Fatal, "Can't append successful result: #{result.inspect}" if result.success?

                merge(result, key)
              end
            end
          end
        end
      end
    end
  end
end
