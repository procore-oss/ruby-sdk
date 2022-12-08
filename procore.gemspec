# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "procore/version"

Gem::Specification.new do |spec|
  spec.name          = "procore"
  spec.version       = Procore::VERSION
  spec.authors       = ["Procore Engineering"]
  spec.email         = ["opensource@procore.comm"]

  spec.summary       = "Procore Ruby Gem"
  spec.description   = "Procore Ruby Gem"
  spec.homepage      = "https://github.com/procore/ruby-sdk"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "actionpack"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "dalli"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "webmock"

  spec.add_dependency "activesupport", "> 2.4"
  spec.add_dependency "oauth2", "~> 2.0"
  spec.add_dependency "rest-client", "~> 2.0.0"
end
