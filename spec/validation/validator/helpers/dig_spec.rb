# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../lib/lite/validation/validator/option'
require_relative '../../../../lib/lite/validation/validator/helpers/path'

module Lite
  module Validation
    module Validator
      module Option
        module Some
          RSpec.describe '#dig' do
            let(:complex_value) do
              hash = {
                foo: 'FOO',
                bar: 'BAR',
                bax: { a: 5, b: 8 },
                qox: { a: -5, b: -8 }
              }
              Option.some(hash)
            end
            let(:path) { Validator::Helpers::Path.expand_path(from, []) }

            context 'with immediate single key' do
              let(:from) { [:foo] }

              it 'fetches single value' do
                expect(complex_value.dig(path))
                  .to eq(Option.some('FOO'))
              end
            end

            context 'with immediate tuple' do
              let(:from) { [%i[foo bar]] }

              it 'fetches tuple' do
                expect(complex_value.dig(path))
                  .to eq(Complex::Wrappers::Tuple.new([Option.some('FOO'), Option.some('BAR')]))
              end
            end

            context 'with path to single key' do
              let(:from) { %i[bax a] }

              it 'fetches single value' do
                expect(complex_value.dig(path))
                  .to eq(Option.some(5))
              end
            end

            context 'with path to tuple' do
              let(:from) { [:bax, %i[a b]] }

              it 'fetches tuple' do
                expect(complex_value.dig(path))
                  .to eq(Complex::Wrappers::Tuple.new([Option.some(5), Option.some(8)]))
              end
            end

            context 'with tuple of immediate keys and a path to single key' do
              let(:from) { [[:foo, :bar, %i[bax a]]] }

              it 'fetches tuple of three' do
                expect(complex_value.dig(path))
                  .to eq(Complex::Wrappers::Tuple.new([Option.some('FOO'), Option.some('BAR'), Option.some(5)]))
              end
            end

            context 'with tuple of immediate single key and a path to tuple' do
              let(:from) { [[:foo, [:bax, %i[a b]]]] }

              it 'fetches tuple of three' do
                expect(complex_value.dig(path))
                  .to eq(Complex::Wrappers::Tuple.new([Option.some('FOO'), Option.some(5), Option.some(8)]))
              end
            end

            context 'with tuple of branching path and straight path' do
              let(:from) { [[[:bax, %i[a b]], %i[qox b]]] }

              it 'fetches all values in a tuple' do
                expect(complex_value.dig(path))
                  .to eq(Complex::Wrappers::Tuple.new([Option.some(5), Option.some(8), Option.some(-8)]))
              end
            end

            context 'with tuple of multiple immediate single key and multiple paths to single key' do
              let(:from) { [[:foo, :bar, %i[bax a], %i[qox b]]] }

              it 'fetches all values in a tuple' do
                expect(complex_value.dig(path))
                  .to eq(Complex::Wrappers::Tuple.new([Option.some('FOO'), Option.some('BAR'), Option.some(5), Option.some(-8)]))
              end
            end

            context 'with tuple followed by a path' do
              let(:from) { [%i[bax qox], :a] }

              it 'raises error' do
                expect { path }
                  .to raise_error(Helpers::Path::InvalidPath, "Can't follow path into a tuple: [:bax, :qox] -> :a")
              end
            end
          end
        end
      end
    end
  end
end
