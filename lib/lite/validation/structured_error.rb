# frozen_string_literal: true

module Lite
  module Validation
    module StructuredError
      def code
        raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
      end

      def message
        nil
      end

      def display_message(*)
        nil
      end

      def data
        nil
      end
    end
  end
end
