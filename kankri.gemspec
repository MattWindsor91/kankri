# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kankri/version'

Gem::Specification.new do |spec|
  spec.name          = 'kankri'
  spec.version       = Kankri::VERSION
  spec.authors       = ['Matt Windsor']
  spec.email         = ['matt.windsor@ury.org.uk']
  spec.description   = %q{
    Kankri is a library for quickly setting up basic authentication with
    object-action privileges.  It's intended to be used in projects which need
    a simple auth system with no run-time requirements and little set-up.  It
    isn't intended for mission critical security.
  }
  spec.summary       = 'Simple object-action privilege checking'
  spec.homepage      = 'https://github.com/CaptainHayashi/kankri'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10', '>= 10.1.1'
  spec.add_development_dependency 'rspec', '~> 2', '>= 2.14'
  spec.add_development_dependency 'simplecov', '~> 0.8'
  spec.add_development_dependency 'fuubar', '~> 1'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'yardstick', '~> 0.9'
  spec.add_development_dependency 'backports', '~> 3', '>= 3.3.5'
end
