# frozen_string_literal: true

require_relative 'iterable'
require_relative '../disputable/navigable'
require_relative 'abstract/collect'

module Lite
  module Validation
    module Validator
      module Result
        module Valid
          class Navigable < Abstract::Instance
            include Disputable::Navigable
            include Abstract::Collect

            def self.instance(*args)
              new(EMPTY, *args)
            end

            def initialize(children, *args)
              super(children.freeze, *args)
            end

            def auto_commit(as:)
              commit(collect_committed(as: as))
            end

            def dispute(error)
              Disputed::Navigable.instance(error: error)
            end

            def success
              Option.none
            end

            def inspect
              signature('Valid::Navigable', nil)
            end

            def iterable(commit:)
              Iterable.instance(children, commit: commit)
            end

            def merge(result, key)
              if result.success?
                self.class.send(
                  :new,
                  children.merge(key => result)
                )
              else
                Disputed::Navigable.instance.append(result, key)
              end
            end

            private

            def collect_committed_as_array
              children.values
                      .lazy
                      .select(&:committed?)
                      .map(&:value).force
            end
          end
        end
      end
    end
  end
end
