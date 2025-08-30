# frozen_string_literal: true

require_relative 'abstract'
require_relative 'complex'
require_relative 'singular'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          class Simple < Abstract
            include Singular

            def to_complex
              Complex.instance(value)
            end
          end
        end
      end
    end
  end
end
