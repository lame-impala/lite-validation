# frozen_string_literal: true

require_relative '../../error'

module Lite
  module Validation
    module Validator
      module Helpers
        module Path
          class InvalidPath < Error::Fatal; end

          def self.expand_path(path, base_path)
            return [base_path] if path.empty?

            element, *rest = path

            case element
            when ::Array
              raise InvalidPath, <<~ERR.chomp unless rest.empty?
                Can't follow path into a tuple: #{element} -> #{rest.map(&:inspect).join(', ')}
              ERR

              expand_tuple(element, base_path)
            else
              expand_path(rest, [*base_path, element])
            end
          end

          def self.expand_tuple(tuple, base_path)
            tuple.flat_map do |element|
              expand_element(element, base_path)
            end
          end

          def self.expand_element(element, base_path)
            case element
            when ::Array
              raise InvalidPath, "Empty path in a tuple: #{base_path.join(', ')}" if element.empty?

              expand_path(element, base_path)
            else
              [[*base_path, element]]
            end
          end
        end
      end
    end
  end
end
