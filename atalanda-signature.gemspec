# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atalanda/signature/version'

Gem::Specification.new do |spec|
  spec.name          = "atalanda-signature"
  spec.version       = Atalanda::Signature::VERSION
  spec.authors       = ["Dominik Goltermann"]
  spec.email         = ["dominik@goltermann.cc"]
  spec.description   = %q{Gem for signing atalogics api calls}
  spec.summary       = %q{Gem for signing atalogics api calls}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "debugger"
end
