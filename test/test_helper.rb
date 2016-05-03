$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "serviceworker/rails"

require "minitest/autorun"
require "minitest/pride"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
