# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Identity
            def self.intent_id
              @count ||= 0
              @count += 1
            end

            def self.ensure_identical!(origin, current)
              return if origin.identical?(current)

              raise_error!(origin, current, origin.send(:intent) == current.send(:intent) ? :origin : :intent)
            end

            def self.raise_error!(origin, current, key)
              full = key == :intent
              message = "Not the #{key}: #{origin.send(:display_path, full)} <> #{current.send(:display_path, full)}"
              raise Error::Fatal, message
            end

            def self.display_path(full_path)
              case full_path
              when Array then "[#{full_path.map { |element| display_path_element(element) }.join(',')}]"
              else full_path
              end
            end

            def self.display_path_element(element)
              case element
              when Array then "(#{element.map { |path| display_path(path) }.join(',')})"
              else element
              end
            end

            def identical?(other)
              return true if other.equal?(self)
              return false unless other.path == path
              return true if other.parent.equal?(parent)
              return false if other.root? || root?

              other.parent.identical?(parent)
            end

            def key
              path.last
            end

            def full_path(full)
              if root?
                full ? path : []
              else
                parent.full_path(full) + path
              end
            end

            def display_path(full)
              Identity.display_path(full_path(full))
            end

            def path_to(ancestor)
              trace(ancestor, trace: [])
            end

            def intent
              root? ? path.first : parent.intent
            end

            def root?
              parent.nil?
            end

            protected

            def trace(ancestor, trace: [])
              return trace if ancestor.identical?(self)
              return if root?

              parent.trace(ancestor, trace: path + trace)
            end
          end
        end
      end
    end
  end
end
