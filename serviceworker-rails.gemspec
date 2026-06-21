# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "serviceworker/rails/version"

Gem::Specification.new do |spec|
  spec.name = "serviceworker-rails"
  spec.version = ServiceWorker::Rails::VERSION
  spec.authors = ["Ross Kaffenberger"]
  spec.email = ["rosskaff@gmail.com"]

  spec.summary = "ServiceWorker for Rails 7+"
  spec.description = "Integrates ServiceWorker into the Rails asset pipeline."
  spec.homepage = "https://github.com/rossta/serviceworker-rails"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "rack", [">= 2.1"]
  spec.add_dependency "logger"
  spec.add_dependency "benchmark"
  spec.add_dependency "bigdecimal"
  spec.add_dependency "ostruct"
  spec.add_dependency "mutex_m"
  spec.add_dependency "drb"
  spec.add_dependency "cgi"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "parallel", "~> 1.27"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sprockets", "~> 3.0"
  spec.add_development_dependency "sprockets-rails"
  spec.add_development_dependency "standard"
end
