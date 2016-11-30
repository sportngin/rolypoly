# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rolypoly/version'

Gem::Specification.new do |spec|
  spec.name          = "rolypoly"
  spec.version       = Rolypoly::VERSION
  spec.authors       = ["Jon Phenow"]
  spec.email         = ["j.phenow@gmail.com"]
  spec.description   = %q{Tools for handling per-action and per-app Role authorization}
  spec.summary       = %q{Tools for handling per-action and per-app Role authorization}
  spec.homepage      = "https://github.com/sportngin/rolypoly"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
