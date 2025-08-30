# frozen_string_literal: true

require_relative 'abstract'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Registry
              class Root < Abstract
                def self.instance(children: [])
                  new children.freeze
                end

                def insert(key, wrapper)
                  super(Node.instance(key, wrapper))
                end

                def describe
                  describe_children(0).join("\n")
                end
              end
            end
          end
        end
      end
    end
  end
end
