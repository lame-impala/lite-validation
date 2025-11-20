# frozen_string_literal: true

require_relative 'implementation/apply_ruling'
require_relative 'implementation/navigation'
require_relative 'implementation/identity'
require_relative 'implementation/iteration'
require_relative 'implementation/predication'
require_relative 'implementation/scoping'
require_relative 'implementation/transformation'

module Lite
  module Validation
    module Validator
      module Node
        module Abstract
          include Implementation::Identity
          include Implementation::ApplyRuling
          include Implementation::Navigation
          include Implementation::Iteration
          include Implementation::Predication
          include Implementation::Scoping
          include Implementation::Transformation
        end
      end
    end
  end
end
