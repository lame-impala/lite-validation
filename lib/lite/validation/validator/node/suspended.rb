# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Node
        class Suspended
          def initialize(action, node, path, from, *args)
            @action = action
            @node = node
            @path = path
            @from = from
            @args = args
          end

          attr_reader :action, :node, :path, :from, :args

          def option(&block)
            node.send(action, path, from, :yield_option, *args, block)
          end

          def some(&block)
            node.send(action, path, from, :skip, *args, block)
          end

          def some_or_nil(&block)
            node.send(action, path, from, :nullify, *args, block)
          end
        end
      end
    end
  end
end
