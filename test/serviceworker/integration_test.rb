require "rails_helper"

class ServiceWorker::IntegrationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    ::Rails.application
  end

  def test_homepage
    get "/"

    assert last_response.ok?
    assert_match %r{Hello, World}, last_response.body
  end

  def test_serviceworker_request
    get "/"
    get "/serviceworker.js"

    assert last_response.ok?
    assert_equal "application/javascript", last_response.headers["Content-Type"]
    assert_equal "private, max-age=0, no-cache", last_response.headers["Cache-Control"]
    assert_match %r{console.log\(.*'Hello from ServiceWorker!'.*\);}, last_response.body
  end

  def test_custom_header
    get "/"
    get "/serviceworker.js"

    assert_equal "foobar", last_response.headers["X-Custom-Header"]
  end
end
