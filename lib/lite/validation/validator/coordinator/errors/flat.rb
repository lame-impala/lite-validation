# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Coordinator
        module Errors
          module Flat
            def self.build(result)
              build_recursively(result)
            end

            def self.build_recursively(result, path: [])
              errors_root = result.send(:errors_root)
              return build_nested(result, path) if errors_root.empty?

              [[stringify_path(path), errors_root], *build_nested(result, path)]
            end

            def self.build_nested(result, path)
              result.send(:children).flat_map do |key, child|
                build_recursively(child, path: [*path, key])
              end
            end

            def self.stringify_path(path)
              case path
              when Array then path.map { stringify_key(_1) }.join('.')
              else path.to_s.freeze
              end
            end

            def self.stringify_key(key)
              case key
              when Array then "(#{key.map { stringify_path(_1) }.join(',')})"
              else key.to_s.freeze
              end
            end

            private_class_method :build_recursively, :build_nested
          end
        end
      end
    end
  end
end
