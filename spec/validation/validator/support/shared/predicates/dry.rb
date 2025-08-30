# frozen_string_literal: true

require_relative '../predicates'
require_relative '../../../../../../lib/lite/validation/validator/adapters/predicates/dry'

module Lite
  module Validation
    module Validator
      module Support
        module Shared
          module Predicates
            module Dry
              # rubocop:disable Security/Eval
              eval(ReadmeHelper.snippet!(:predication_define_native))
              eval(ReadmeHelper.snippet!(:predication_foreign_configuration))
              eval(ReadmeHelper.snippet!(:predication_define_foreign))
              # rubocop:enable Security/Eval

              Presence = Predicate::Registry.predicate(:presence)
            end
          end
        end
      end
    end
  end
end
