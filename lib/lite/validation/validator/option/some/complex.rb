# frozen_string_literal: true

require_relative 'complex/wrappers'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            def self.instance(object)
              return object if object.is_a?(Complex)

              wrapper = Registry.wrapper_for(object.class)
              raise Error::Fatal, "No wrapper for: #{object.class}" unless wrapper

              wrapper.new(object)
            end
          end
        end
      end
    end
  end
end
