require "rails_helper"

class ServiceWorker::IntegrationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    ::Rails.application
  end

  def setup
    get "/"
  end

  def test_homepage
    assert last_response.ok?
    assert_match %r{Hello, World}, last_response.body
  end

  def test_serviceworker_request
    get "/serviceworker.js"

    assert last_response.ok?
    assert_equal "application/javascript", last_response.headers["Content-Type"]
    assert_equal "private, max-age=0, no-cache", last_response.headers["Cache-Control"]
    assert_match %r{console.log\(.*'Hello from ServiceWorker!'.*\);}, last_response.body
  end

  def test_custom_header
    get "/serviceworker.js"

    assert_equal "foobar", last_response.headers["X-Custom-Header"]
  end

  def test_nested_serviceworker_proxy
    get "/nested/serviceworker.js"

    assert last_response.ok?
    assert_match %r{console.log\(.*'Hello from Another ServiceWorker!'.*\);}, last_response.body
  end

  def test_inline_header_serviceworker_proxy
    get "/header-serviceworker.js"

    assert last_response.ok?
    assert_match %r{console.log\(.*'Hello from Another ServiceWorker!'.*\);}, last_response.body
  end

  def test_globbed_serviceworker_proxy
    get "/catchall/serviceworker.js"

    assert last_response.ok?
    assert_match %r{console.log\(.*'Hello from Fallback ServiceWorker!'.*\);}, last_response.body
  end

  def test_not_found_serviceworker_proxy
    assert_raises ActionController::RoutingError do
      get "/not/found/service/worker.js"
    end
  end

  def test_precompiled_serviceworker_request
    Rails.application.config.assets.stub(:compile, false) do
      get "/serviceworker.js"

      assert last_response.ok?
      assert_equal "application/javascript", last_response.headers["Content-Type"]
      assert_equal "private, max-age=0, no-cache", last_response.headers["Cache-Control"]
      assert_match %r{console.log\(.*'Hello from ServiceWorker!'.*\);}, last_response.body
    end
  end
end
