# frozen_string_literal: true

require_relative 'validator/node'
require_relative 'validator/coordinator'
require_relative 'validator/predicate'

module Lite
  module Validation
    module Validator
      def self.instance(*args, **opts)
        Node::Root.initial(*args, **opts)
      end
    end
  end
end
