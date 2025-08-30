# frozen_string_literal: true

require 'lite/data'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Complex
            module Registry
              class Abstract
                Lite::Data.define(self, args: [:children])

                private_class_method :new

                def self.insert(node, children)
                  updated = insert_as_child(node, children)
                  return updated if updated

                  insert_as_parent(node, children)
                end

                def self.insert_as_child(node, children)
                  parents, unrelated = children.partition { |child| child.key >= node.key }

                  case parents.length
                  when 0 then nil
                  when 1
                    [parents.first.insert(node), *unrelated]
                  else
                    raise Error, "Multiple parents found for #{node.key}: #{parents.map(&:key).join(', ')}"
                  end
                end

                def self.insert_as_parent(node, children)
                  descendants, unrelated = children.partition { |child| child.key < node.key }

                  if descendants.empty?
                    [*unrelated, node]
                  else
                    [node.with(children: descendants.freeze), *unrelated]
                  end
                end

                def insert(node)
                  with(children: self.class.insert(node, children).freeze)
                end

                def wrapper_for(key)
                  provider = children.find { |candidate| candidate.key >= key }
                  provider&.wrapper_for(key)
                end

                private

                def describe_children(severity)
                  children.flat_map { |child| child.describe(severity) }
                end
              end
            end
          end
        end
      end
    end
  end
end
