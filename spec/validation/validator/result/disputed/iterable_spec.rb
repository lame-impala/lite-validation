# frozen_string_literal: true

require 'spec_helper'

require_relative '../support/test_reducer'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          RSpec.describe Iterable do
            let(:result) do
              Node::TestReducer.reduce(iterable, data, block)
            end
            let(:data) { [5, 6] }
            let(:block) do
              lambda { |_iterable, _key, value, result, _context|
                [result.dispute(StructuredError::Record.instance(:"err#{value}")), nil]
              }
            end

            describe Iterable::Array do
              let(:iterable) { described_class.instance }
              let(:expected_children) do
                [
                  [0, have_attributes(errors_root: [have_attributes(code: :err5)])],
                  [1, have_attributes(errors_root: [have_attributes(code: :err6)])]
                ]
              end

              it 'stores errors in an array of tuples' do
                expect(result.children)
                  .to match(expected_children)
              end
            end

            describe Iterable::Hash do
              let(:iterable) { described_class.instance([], {}) }
              let(:expected_children) do
                {
                  0 => have_attributes(errors_root: [have_attributes(code: :err5)]),
                  1 => have_attributes(errors_root: [have_attributes(code: :err6)])
                }
              end

              it 'stores errors in an array of tuples' do
                expect(result.children)
                  .to match(expected_children)
              end
            end
          end
        end
      end
    end
  end
end
