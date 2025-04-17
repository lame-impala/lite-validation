# frozen_string_literal: true

require 'lite/local_env'

Lite::LocalEnv.load_into(ENV)

source 'https://rubygems.org'
gemspec

gem 'lite-data', git: "https://#{ENV.fetch('BITBUCKET', nil)}@bitbucket.org/TomMix/lite-data", branch: :main

group :test do
  gem 'activemodel'
  gem 'byebug', '~> 11'
  gem 'dry-logic'
  gem 'dry-monads'
  gem 'dry-validation'
  gem 'markly'
  gem 'rspec', '~> 3'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'simplecov'
end
