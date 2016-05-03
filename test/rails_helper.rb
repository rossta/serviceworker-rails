# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/sample/config/environment.rb", __FILE__)

require "test_helper"

require "rack/test"
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
