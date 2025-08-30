# frozen_string_literal: true

require_relative '../../abstract/instance'
require_relative '../../../disputable/iterable/array'
require_relative '../../abstract/commit'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Iterable
            module Array
              module Abstract
                include Disputable::Iterable::Array
                include Valid::Abstract::Commit
              end
            end
          end
        end
      end
    end
  end
end
