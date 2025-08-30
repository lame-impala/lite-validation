# frozen_string_literal: true

require_relative '../abstract'

module Lite
  module Validation
    module Validator
      module Node
        module Abstract
          module Branch
            include Abstract

            def inspect
              "Branch #{super}"
            end
          end
        end
      end
    end
  end
end
