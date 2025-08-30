# frozen_string_literal: true

require_relative 'predicate/registry'
require_relative 'predicate/native/builder'

module Lite
  module Validation
    module Validator
      module Predicate
        def self.define(name, &block)
          predicate = Native::Builder.define(&block)
          Registry.register_predicate(name, predicate)
        end
      end
    end
  end
end
