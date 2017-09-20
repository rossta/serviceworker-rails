require "test_helper"

class ServiceWorker::HandlersTest < Minitest::Test
  def test_build_handler
    handler_given = ->() { [200, {}, "console.log('Foobar!');"] }
    handler = ServiceWorker::Handlers.build(handler_given)

    assert_equal handler_given, handler
  end

  def test_build_sprockets_handler
    handler = ServiceWorker::Handlers.build(:sprockets)

    assert handler.is_a?(ServiceWorker::Handlers::SprocketsHandler)
  end

  def test_build_webpacker_handler
    return true unless defined?(::Webpacker)
    handler = ServiceWorker::Handlers.build(:webpacker)

    assert handler.is_a?(ServiceWorker::Handlers::WebpackerHandler)
  end

  def test_build_rack_handler
    handler = ServiceWorker::Handlers.build(:rack)

    assert handler.is_a?(ServiceWorker::Handlers::RackHandler)
  end

  def test_build_unknown_handler
    assert_raises ServiceWorker::Error do
      ServiceWorker::Handlers.build(:unknown)
    end
  end
end
