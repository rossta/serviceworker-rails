# frozen_string_literal: true

ENV["RAILS_ENV"] = ENV["RACK_ENV"] = "test"

require "simplecov"
require "coveralls"
SimpleCov.maximum_coverage_drop 5
Coveralls.wear! do
  add_filter "test"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require File.expand_path("../../test/sample/config/environment.rb", __FILE__)

require "rack/test"
require "rails/test_help"
require "minitest/autorun"
require "minitest/pride"

require "serviceworker-rails"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
