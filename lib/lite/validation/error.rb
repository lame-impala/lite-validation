# frozen_string_literal: true

module Lite
  module Validation
    class Error < StandardError
      class Fatal < Error; end
    end
  end
end
