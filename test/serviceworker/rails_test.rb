require "test_helper"

class ServiceWorker::RailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    assert ::ServiceWorker::Rails::VERSION
  end
end
