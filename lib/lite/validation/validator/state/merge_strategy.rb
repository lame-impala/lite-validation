# frozen_string_literal: true

module Lite
  module Validation
    module Validator
      module State
        module MergeStrategy
          module Standard
            def self.transform_result(result, _origin, _partial_path)
              result
            end

            def self.inspect
              '#<MergeStrategy::Standard>'
            end
          end

          class Critical
            def initialize(section_start, error_generator)
              @section_start = section_start
              @error_generator = error_generator
              freeze
            end

            def transform_result(result, origin, partial_path)
              return result unless result.refuted?
              return result if partial_path.nil? || partial_path.empty?

              error = result.fall_through ? result.error : transform_error(result.error, origin, partial_path)
              origin.result.refute(error, fall_through: true)
            end

            def transform_error(error, origin, partial_path)
              trace = origin.path_to(section_start)
              error_generator.call(error, trace + partial_path)
            end

            def inspect
              '#<MergeStrategy::Critical>'
            end

            private

            attr_reader :section_start, :error_generator
          end
        end
      end
    end
  end
end
