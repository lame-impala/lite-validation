# frozen_string_literal: true

require_relative '../suspended'
require_relative 'dig'
require_relative 'helpers/call_foreign'
require_relative 'helpers/yield_strategy'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Validation
            # rubocop:disable Metrics/ParameterLists
            def self.validate(coordinator, to_yield, result, context, commit, block)
              updated = Helpers::CallForeign.call_foreign(result, coordinator) do
                ruling = block.call(to_yield, context)
                Validator::Ruling.apply(ruling.nil? ? Validator::Ruling::Pass() : ruling, result, coordinator)
              end

              case commit
              when false then updated
              when true then updated.commit(to_yield)
              else raise Error::Fatal, "Invalid commit argument. Expected boolean, got: #{commit.inspect}"
              end
            end
            # rubocop:enable Metrics/ParameterLists

            def validate?(*path, from: nil, commit: false, &block)
              from = Validator::Helpers::Path.expand_path(from || path, [])
              return Suspended.new(:validate!, self, path, from, commit) if block.nil?

              validate!(path, from, :skip, commit, block)
            end

            def validate(*path, from: nil, commit: false, &block)
              from = Validator::Helpers::Path.expand_path(from || path, [])
              validate!(path, from, :refute, commit, block)
            end

            private

            def validate!(path, from, strategy, commit, block)
              strategy = Helpers::YieldStrategy.to_yield(strategy)
              dig!(path, from) do |option, result|
                updated = strategy.block_parameters(self, option, result) do |to_yield|
                  Validation.validate(
                    coordinator,
                    to_yield,
                    result,
                    context,
                    commit,
                    block
                  )
                end
                merge_strategy.transform_result(updated, self, path)
              end
            end
          end
        end
      end
    end
  end
end
