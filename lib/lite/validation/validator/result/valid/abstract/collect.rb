# frozen_string_literal: true

require_relative 'commit'
require_relative '../../../../error'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          module Abstract
            module Collect
              include Commit

              private

              def collect_committed(as:)
                case as
                when :array then collect_committed_as_array
                when :hash then collect_committed_as_hash
                else raise Error::Fatal, "Unexpected option: #{as}"
                end
              end

              def collect_committed_as_hash
                each_child({}) do |(key, child), acc|
                  next unless child.committed?

                  acc[key] = child.send :value
                end
              end

              def each_child(initial_object, &block)
                children.each_with_object(initial_object, &block)
              end
            end
          end
        end
      end
    end
  end
end
