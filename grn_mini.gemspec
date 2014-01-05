# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grn_mini/version'

Gem::Specification.new do |spec|
  spec.name          = "grn_mini"
  spec.version       = GrnMini::VERSION
  spec.authors       = ["ongaeshi"]
  spec.email         = ["ongaeshi0621@gmail.com"]
  spec.summary       = %q{Groonga(Rroonga) wrapper for use as the KVS.}
  spec.description   = %q{Groonga(Rroonga) for using easily. You can add the data in the column without specifying. You can easy to use and persistence, advanced search query, sort, grouping (drill down), snippets, and pagination. You can make an immediate search engine.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"

  spec.add_dependency "rroonga"
end
