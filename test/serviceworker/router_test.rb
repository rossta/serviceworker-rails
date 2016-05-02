require "test_helper"

class ServiceWorker::RouterTest < Minitest::Test
  def setup
    @router = ServiceWorker::Router.new
  end

  def test_router_empty_routes
    assert_equal @router.routes, []
    refute @router.any?
  end

  def test_match_adds_route
    route = @router.match("/path", foo: "bar")

    assert_equal route.path_pattern, "/path"
    assert_equal route.options, { foo: "bar" }
  end

  def test_get_aliased_to_match
    route = @router.get("/path", foo: "bar")

    assert_equal route.path_pattern, "/path"
    assert_equal route.options, { foo: "bar" }
  end

  def test_draw_adds_given_routes
    @router.draw do
      match "/foo"
      match "/bar"
    end
    paths = @router.routes.map(&:path_pattern)

    assert_equal paths, ["/foo", "/bar"]
  end

  def test_draw_default
    @router.draw_default
    paths = @router.routes.map(&:path_pattern)

    assert_equal paths, ["/serviceworker.js"]
  end

  def test_match_route_matches
    @router.draw do
      match "/foo"
      match "/bar"
    end

    assert_equal @router.match_route("PATH_INFO" => "/foo").to_a, ["/foo", "foo", {}]
    assert_equal @router.match_route("PATH_INFO" => "/bar").to_a, ["/bar", "bar", {}]
  end

  def test_match_route_doesnt_match
    @router.draw do
      match "/foo"
      match "/bar"
    end

    refute @router.match_route("PATH_INFO" => "/not/found")
  end
end
