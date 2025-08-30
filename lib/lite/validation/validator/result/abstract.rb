# frozen_string_literal: true

require_relative '../../result/abstract'
require_relative '../../result/abstract/disputable'
require_relative '../../result/abstract/refutable'
require_relative '../../error'

module Lite
  module Validation
    module Validator
      module Result
        module Abstract
          include Validation::Result::Abstract
          include Validation::Result::Abstract::Disputable
          include Validation::Result::Abstract::Refutable

          EMPTY = {}.freeze

          private

          def signature(name, data)
            full_name = "Result::#{name}"
            "#<#{[full_name, data].compact.join(' ')}>"
          end
        end
      end
    end
  end
end
