# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

require_relative '../../validator/support/functional/coordinators/dry'
require_relative '../../validator/support/shared/predicates/dry'

module Lite
  module Validation
    module Validator
      describe 'README' do
        # rubocop:disable RSpec/NoExpectationExample, Security/Eval
        include Ruling::Constructors

        let(:coordinator) { Validator::Support::Functional::Coordinators::Dry::Hierarchical }

        describe 'with error adapters' do
          let(:result) do
            validator
              .validate { |_data, _ctx| Dispute(root_error) }
              .at(:foo, :bar) { |bar| bar.validate { |_foo, _ctx| Dispute(bar_error) } }
              .to_result
          end
          let(:validator) { Validator.instance(data, coordinator, context: context) }
          let(:context) { nil }
          let(:data) { { foo: { bar: 5 } } }
          let(:root_error) { StructuredError::Record.instance(:root_error) }
          let(:bar_error) { StructuredError::Record.instance(:bar_error) }

          context 'with hierarchical adapter' do
            it 'describes the correct structure' do
              eval(ReadmeHelper.snippet!(:with_hierarchical_adapter))
            end
          end

          context 'with flat adapter' do
            let(:coordinator) { Validator::Support::Functional::Coordinators::Dry::Flat }

            it 'describes the correct structure' do
              eval(ReadmeHelper.snippet!(:with_flat_adapter))
            end
          end

          context 'with dry adapter' do
            let(:coordinator) { Validator::Support::Functional::Coordinators::Dry::Dry }

            it 'describes the correct structure' do
              eval(ReadmeHelper.snippet!(:with_dry_adapter))
            end
          end
        end

        describe 'validation' do
          context 'when validating a scalar' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:validation_scalar))
            end
          end

          context 'when validating a hash' do
            context 'when the path at and path from are aligned' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:validation_hash_aligned))
              end
            end

            context 'when the path at and path from are unaligned' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:validation_hash_unaligned))
              end
            end

            context 'when validating tuple at an unaligned path' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:validation_hash_tuple_unaligned))
              end
            end

            context 'when calling disputed on the node' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:node_disputed))
              end
            end

            context 'when validate? block receives an option' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:validation_option))
              end
            end

            context 'when validating an object' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:validation_object))
              end
            end

            context 'when validating an object calling unimplemented reader' do
              it 'describes the process correctly' do
                eval(ReadmeHelper.snippet!(:validation_object_reader_unimplemented))
              end
            end
          end
        end

        describe 'predication' do
          context 'when calling declared predicates' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:predication_satisfy_declared))
            end
          end

          context 'when calling contextual predicates' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:predication_satisfy_contextual))
            end
          end
        end

        describe 'navigation' do
          context 'when accessing a nested node' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:navigation_nested_node))
            end
          end

          context 'when accessing a nested node in an array' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:navigation_nested_node_each))
            end
          end

          context 'when validating a nested value in an array' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:navigation_nested_node_each_validate))
            end
          end

          context 'when testing a predicate on a nested value in an array' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:navigation_nested_node_each_satisfy))
            end
          end
        end

        describe 'with_valid' do
          context 'when checking for valid node' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:scoping_with_valid_node))
            end
          end

          context 'when checking for valid children' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:scoping_with_valid_children))
            end
          end
        end

        describe 'critical' do
          context 'when nested node refuted in a critical section' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:scoping_critical_refute_nested))
            end
          end

          context 'when critical error is re-wrapped' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:scoping_critical_rewrap_error))
            end
          end
        end

        describe 'ruling' do
          context 'with complex structure being committed' do
            it 'describes the process correctly' do
              eval(ReadmeHelper.snippet!(:ruling_commit_complex))
            end
          end
        end
        # rubocop:enable RSpec/NoExpectationExample, Security/Eval
      end
    end
  end
end
