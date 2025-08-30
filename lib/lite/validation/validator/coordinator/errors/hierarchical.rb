# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Coordinator
        module Errors
          module Hierarchical
            def self.build(result)
              root_errors = result.send(:errors_root)
              children = result.send(:children).each_with_object({}) do |(key, child), acc|
                child_errors = build(child)
                acc[key] = child_errors unless child_errors.empty?
              end

              if children.empty?
                { errors: root_errors }
              elsif root_errors.empty?
                { children: children }
              else
                { errors: root_errors, children: children }
              end
            end
          end
        end
      end
    end
  end
end
