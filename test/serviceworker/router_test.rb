require "test_helper"

class ServiceWorker::RouterTest < Minitest::Test
  def setup
    @router = ServiceWorker::Router.new
  end

  def test_router_empty_routes
    assert_equal @router.routes, []
    refute @router.any?
  end

  def test_get_adds_route
    route = @router.get("/path", foo: "bar")

    assert_equal route.path, "/path"
    assert_equal route.options, { foo: "bar" }
  end

  def test_draw_adds_given_routes
    @router.draw do
      get "/foo"
      get "/bar"
    end
    paths = @router.routes.map(&:path)

    assert_equal paths, ["/foo", "/bar"]
  end

  def test_draw_default
    @router.draw_default
    paths = @router.routes.map(&:path)

    assert_equal paths, ["/serviceworker.js"]
  end

  def test_match_route_matches
    @router.draw do
      get "/foo"
      get "/bar"
    end
    foo, bar = @router.routes

    assert_equal @router.match_route("/foo"), foo
    assert_equal @router.match_route("/bar"), bar
  end

  def test_match_route_doesnt_match
    @router.draw do
      get "/foo"
      get "/bar"
    end

    refute @router.match_route("/not/found")
  end
end
