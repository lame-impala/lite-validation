# frozen_string_literal: true

require_relative 'abstract/invalid'

module Lite
  module Validation
    module Validator
      module Ruling
        class Dispute < Ruling::Abstract::Invalid
          module Abstract; end

          class Raw < Ruling::Abstract::Invalid::Raw
            include Abstract
          end

          include Abstract
        end
      end
    end
  end
end
