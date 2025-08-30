# frozen_string_literal: true

require_relative 'validation'
require_relative '../../predicate/registry'

module Lite
  module Validation
    module Validator
      module Node
        module Implementation
          module Predication
            include Validation

            def self.resolve_predicate(using, path, context, block)
              object = call_builder_block(using, path, context, block)
              fetch_predicate(object)
            end

            def self.call_builder_block(using, path, context, block)
              case using
              when nil then block.call(context)
              else
                engine = Predicate::Registry.engine(using)
                engine.build_contextual(path, context, &block)
              end
            end

            def self.fetch_predicate(object)
              case object
              when Symbol then Predicate::Registry.predicate(object)
              when Predicate::Abstract::Variants then object
              else raise Error::Fatal, "Unexpected predicate object: #{object.inspect}"
              end
            end

            def satisfy?(*path, from: nil, using: nil, severity: :dispute, commit: false, &block)
              return Suspended.new(:satisfy!, self, path, from, using, severity, commit) if block.nil?

              satisfy!(path, from, :skip, using, severity, commit, block)
            end

            def satisfy(*path, from: nil, using: nil, severity: :dispute, commit: false, &block)
              satisfy!(path, from, :refute, using, severity, commit, block)
            end

            private

            # rubocop:disable Metrics/ParameterLists
            def satisfy!(path, from, strategy, using, severity, commit, block)
              from = Validator::Helpers::Path.expand_path(from || path, [])
              predicate = Predication.resolve_predicate(using, from, context, block)
              variant = strategy == :yield_option ? predicate.optional : predicate.definite
              validate!(path, from, strategy, commit, variant.send(severity))
            end
            # rubocop:enable Metrics/ParameterLists
          end
        end
      end
    end
  end
end
