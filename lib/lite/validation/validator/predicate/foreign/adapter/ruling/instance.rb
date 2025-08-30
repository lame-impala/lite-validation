# frozen_string_literal: true

require 'lite/data'

module Lite
  module Validation
    module Validator
      module Predicate
        module Foreign
          module Adapter
            module Ruling
              class Instance
                Lite::Data.define(self, args: %i[severity ruling_class])

                def dispute
                  severity == :dispute ? self : Ruling.instance(:dispute)
                end

                def refute
                  severity == :refute ? self : Ruling.instance(:refute)
                end

                def to_ruling(error)
                  ruling_class.instance(error)
                end

                private_class_method :new

                private :with
              end
            end
          end
        end
      end
    end
  end
end
