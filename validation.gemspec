# frozen_string_literal: true

require_relative 'lib/lite/validation/version'

Gem::Specification.new do |spec|
  spec.name = 'lite-validation'
  spec.version = Lite::Validation::Version::VERSION
  spec.authors = ['Tomas Milsimer']
  spec.email = ['tomas.milsimer@protonmail.com']

  spec.summary = 'Validation of complex structures'
  spec.description = <<~DESC
    Validation of complex structures
  DESC
  spec.homepage = 'https://github.com/lame-impala/lite-validation'

  spec.required_ruby_version = '>= 3.2.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']
  spec.licenses = ['MIT']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
