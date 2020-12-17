# frozen_string_literal: true

ENV["RAILS_ENV"] = ENV["RACK_ENV"] = "test"

require "simplecov"
SimpleCov.minimum_coverage 75
SimpleCov.maximum_coverage_drop 25

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require File.expand_path("../test/sample/config/environment.rb", __dir__)

require "rack/test"
require "rails/test_help"
require "minitest/autorun"
require "minitest/pride"

require "serviceworker-rails"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
