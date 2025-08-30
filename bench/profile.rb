# frozen_string_literal: true

require 'ruby-prof'
require 'byebug'

require_relative '../spec/validation/validator/support/functional/contracts/hash'
require_relative '../spec/validation/validator/support/functional/coordinators/dry'
require_relative '../spec/validation/validator/support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      module Benchmark
        module Profile
          LiteProf = Support::Functional::Contracts::Hash

          VALID = LiteProf::VALID
          INVALID = LiteProf::INVALID
          CONTEXT = LiteProf::CONTEXT

          def self.run(n) # rubocop:disable Naming/MethodParameterName
            result = RubyProf::Profile.profile do
              n.times do |idx|
                LiteProf.call(
                  data(idx),
                  Support::Functional::Coordinators::Dry::Flat,
                  CONTEXT
                ).to_result
              end
            end

            printer = RubyProf::GraphPrinter.new(result)
            printer.print($stdout, {})
          end

          def self.data(idx)
            (idx % 5).zero? ? INVALID : VALID
          end
        end
      end
    end
  end
end

Lite::Validation::Validator::Benchmark::Profile.run(1000)
