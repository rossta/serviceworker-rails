$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

ENV["RAILS_ENV"] = ENV["RACK_ENV"] = "test"

require "simplecov"

SimpleCov.start do
  add_filter "test/sample"
end

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
