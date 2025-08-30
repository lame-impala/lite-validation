# frozen_string_literal: true

require 'lite/data'

require_relative '../structured_error'

module Lite
  module Validation
    module StructuredError
      class Record
        include StructuredError

        Lite::Data.define(self, args: %i[code message data])

        def self.instance(code, message: nil, data: nil)
          new(code.to_sym, message&.to_s.freeze, data.freeze)
        end

        def display_message(*)
          message
        end

        def inspect
          "#<#{self.class.name} '#{message || code}'>"
        end

        def to_hash
          { code: code }.tap do |hash|
            hash[:message] = message unless message.nil?
            hash[:data] = data unless data.nil?
          end
        end
      end
    end
  end
end
