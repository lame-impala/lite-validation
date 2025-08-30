# frozen_string_literal: true

require 'lite/data'
require_relative 'abstract/valid'

module Lite
  module Validation
    module Validator
      module Ruling
        class Commit
          Lite::Data.define(self, args: [:value])
          include Abstract::Valid
        end
      end
    end
  end
end
