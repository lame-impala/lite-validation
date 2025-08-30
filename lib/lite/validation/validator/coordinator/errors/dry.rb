# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module Coordinator
        module Errors
          module Dry
            def self.build(result)
              root_errors = result.send(:errors_root)
              children = result.send(:children).each_with_object({}) do |(key, child), acc|
                child_errors = build(child)
                acc[key] = child_errors unless child_errors.empty?
              end

              if children.empty?
                root_errors
              elsif root_errors.empty?
                children
              else
                [root_errors, children]
              end
            end
          end
        end
      end
    end
  end
end
