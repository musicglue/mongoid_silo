# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
app = File.expand_path('../app', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
$LOAD_PATH.unshift(app) unless $LOAD_PATH.include?(app)

require 'mongoid_silo/version'

Gem::Specification.new do |gem|
  gem.name          = "mongoid_silo"
  gem.version       = MongoidSilo::VERSION
  gem.authors       = ["John Maxwell"]
  gem.email         = ["john@musicglue.com"]
  gem.description   = %q{MongoidSilo gives a simple way to create static representations of models}
  gem.summary       = %q{MongoidSilo is a bit like a Grain Elevator, but without the grain.}
  gem.homepage      = "https://github.com/musicglue/mongoid_silo"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '~> 3.2.9'
  gem.add_dependency 'mongoid', '~> 3.1.0'
  gem.add_dependency 'sidekiq', '~> 2.7.0'
end
