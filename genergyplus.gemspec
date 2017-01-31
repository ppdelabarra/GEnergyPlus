# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'genergyplus/version'

Gem::Specification.new do |spec|
  spec.name          = "genergyplus"
  spec.version       = EPlusModel::VERSION
  spec.authors       = ["German Molina"]
  spec.email         = ["germolinal@gmail.com"]

  spec.summary       = %q{A Gem that allows handling, creating, modifying and simulating EnergyPlus IDF files.}
  spec.description   = %q{ A Gem that allows handling, creating, modifying and simulating EnergyPlus IDF files, with the purpose of allowing scriptin, optimization, etc. }
  spec.homepage      = "https://github.com/IGD-Labs/genergyplus"
  spec.license       = "GPLv3"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
