# frozen_string_literal: true

require_relative 'abstract/failure'
require_relative 'abstract/success'

module Lite
  module Validation
    module Result
      module Abstract
        def success?
          !failure?
        end
      end
    end
  end
end
