# frozen_string_literal: true

require_relative '../../../ruling'
require_relative 'ruling/instance'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          module Adapter
            module Ruling
              def self.instance(severity)
                case severity
                when :dispute then @dispute ||= Instance.send(:new, :dispute, Validator::Ruling::Dispute)
                when :refute then @refute ||= Instance.send(:new, :refute, Validator::Ruling::Refute)
                else raise Validation::Error::Fatal, 'Unexpected severity'
                end
              end
            end
          end
        end
      end
    end
  end
end
