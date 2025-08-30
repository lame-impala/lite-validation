# frozen_string_literal: true

require_relative '../../ruling'
require_relative 'helpers/with_result'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module ApplyRuling
            include Ruling::Constructors

            def commit(value)
              ApplyRuling.apply_ruling(self, Commit(value))
            end

            def auto_commit(as:)
              Helpers::WithResult.with_result(self, result.auto_commit(as: as))
            end

            def dispute(error, at: nil, **opts)
              ApplyRuling.apply_ruling(self, Dispute(error, **opts), path: at)
            end

            def refute(error, at: nil, **opts)
              ApplyRuling.apply_ruling(self, Refute(error, **opts), path: at)
            end

            def self.apply_ruling(validator, ruling, path: nil)
              return validator if ruling.is_a?(Ruling::Pass)

              updated, _meta = validator.result.navigate(*path) do |result|
                applied = Ruling.apply(ruling, result, validator.coordinator)
                validator.merge_strategy.transform_result(applied, validator, path)
              end
              Helpers::WithResult.with_result(validator, updated)
            end
          end
        end
      end
    end
  end
end
