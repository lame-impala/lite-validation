# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Result
        module Disputable
          module Hash
            def child(key)
              children[key] || Result.valid
            end
          end
        end
      end
    end
  end
end
