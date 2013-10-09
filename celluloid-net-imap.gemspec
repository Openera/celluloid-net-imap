# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'celluloid/net/imap/version'

Gem::Specification.new do |spec|
  spec.name          = "celluloid-net-imap"
  spec.version       = Celluloid::Net::Imap::VERSION
  spec.authors       = ["Shugo Maeda", "Andrew Clunis"]
  spec.email         = ["andrew@orospakr.ca"]
  spec.description   = "A fork of Net::IMAP suitable for use with Celluloid::IO."
  spec.summary       = "Creates no extra threads!"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "celluloid-io", "~> 0.15"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
