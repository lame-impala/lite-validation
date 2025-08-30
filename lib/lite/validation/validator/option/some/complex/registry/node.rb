# frozen_string_literal: true

require_relative 'abstract'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Registry
              class Node < Abstract
                Lite::Data.define(self, args: %i[key wrapper])

                def self.instance(key, wrapper, children: [])
                  raise Error, "Key must be a class, got: #{key.inpect}" unless key.is_a?(Class)

                  new key, wrapper, children.freeze
                end

                private_class_method :new

                def insert(node)
                  if key > node.key
                    super
                  elsif key == node.key
                    with(wrapper: node.wrapper)
                  end
                end

                def wrapper_for(key)
                  return if self.key < key

                  super || wrapper
                end

                def describe(severity)
                  ["#{'--' * severity}#{key}:#{wrapper.class.name}", *describe_children(severity + 1)]
                end
              end
            end
          end
        end
      end
    end
  end
end
