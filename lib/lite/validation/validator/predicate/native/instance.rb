# frozen_string_literal: true

require 'lite/data'

require_relative '../abstract/variants'

module Lite
  module Validation
    module Validator
      module Predicate
        module Native
          class Instance
            Lite::Data.define(self, args: [:proc], kwargs: [:severity])
            include Ruling::Constructors
            include Abstract::Variants

            def initialize(proc, severity: nil)
              super
            end

            def dispute
              with(severity: :dispute)
            end

            def refute
              with(severity: :refute)
            end

            def call(*args, **opts)
              raise Error::Fatal, 'Level not set' unless severity

              ruling = instance_exec(*args, **opts, &proc)
              ruling = Pass() if ruling.nil?
              ruling.invalid { |invalid| invalid.send(severity) }
            end
          end
        end
      end
    end
  end
end
