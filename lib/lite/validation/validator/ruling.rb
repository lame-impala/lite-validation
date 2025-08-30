# frozen_string_literal: true

require_relative 'ruling/pass'
require_relative 'ruling/commit'
require_relative 'ruling/invalidate'
require_relative 'ruling/dispute'
require_relative 'ruling/refute'

require_relative '../error'

module Lite
  module Validation
    module Validator
      module Ruling
        def self.apply(ruling, result, coordinator)
          case ruling
          when Commit then result.commit(ruling.value)
          when Dispute::Abstract then result.dispute(ruling.structured_error(coordinator))
          when Refute::Abstract then result.refute(ruling.structured_error(coordinator))
          when Pass then result
          else raise Error::Fatal, "Ruling expected, got: #{ruling.inspect}"
          end
        end

        module Constructors
          # rubocop:disable Naming/MethodName
          def Pass
            Pass
          end

          def Commit(value)
            Ruling::Commit.new(value)
          end

          def Invalidate(error, **opts)
            Ruling::Invalidate.instance(error, **opts)
          end

          def Dispute(error, **opts)
            Ruling::Dispute.instance(error, **opts)
          end

          def Refute(error, **opts)
            Ruling::Refute.instance(error, **opts)
          end
          # rubocop:enable Naming/MethodName
        end

        extend Constructors
      end
    end
  end
end
