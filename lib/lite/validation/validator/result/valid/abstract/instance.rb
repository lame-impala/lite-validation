# frozen_string_literal: true

require_relative '../../abstract/success'
require_relative '../../disputable/instance'
require_relative '../../committed'
require_relative '../../disputed'
require_relative '../../../option'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Abstract
            class Instance < Disputable::Instance
              include Result::Abstract::Success
            end
          end
        end
      end
    end
  end
end
