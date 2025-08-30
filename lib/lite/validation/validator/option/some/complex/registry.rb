# frozen_string_literal: true

require_relative 'registry/root'
require_relative 'registry/node'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Registry
              def self.register(key, wrapper)
                @root = root.insert(key, wrapper)
              end

              def self.root
                @root ||= Root.instance
              end

              def self.wrapper_for(key)
                root.wrapper_for(key)
              end

              private_constant :Abstract, :Root, :Node
            end
          end
        end
      end
    end
  end
end
