# frozen_string_literal: true

require_relative 'complex/wrappers/tuple'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          module Dig
            def dig(paths)
              if paths.length == 1
                follow_path(paths.first)
              else
                tuple = paths.map { follow_path(_1) }
                Complex::Wrappers::Tuple.new(tuple)
              end
            end

            private

            def follow_path(path)
              path.reduce(self) do |option, key|
                break option if option.none?

                option.to_complex.fetch(key)
              end
            end
          end
        end
      end
    end
  end
end
