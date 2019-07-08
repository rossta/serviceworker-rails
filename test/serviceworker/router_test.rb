# frozen_string_literal: true

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

    assert_equal "/path", route.path_pattern
    assert_equal({ foo: "bar" }, route.options)
  end

  def test_get_aliased_to_match
    route = @router.get("/path", foo: "bar")

    assert_equal "/path", route.path_pattern
    assert_equal({ foo: "bar" }, route.options)
  end

  def test_match_adds_route_with_asset_mapping
    route = @router.match("/path" => "foo.js", foo: "bar")

    assert_equal "/path", route.path_pattern
    assert_equal "foo.js", route.asset_pattern
    assert_equal({ foo: "bar" }, route.options)
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

    path, asset_name, headers, _ = @router.match_route("PATH_INFO" => "/foo").to_a
    assert_equal [path, asset_name, headers], ["/foo", "foo", {}]
    path, asset_name, headers, _ = @router.match_route("PATH_INFO" => "/bar").to_a
    assert_equal [path, asset_name, headers], ["/bar", "bar", {}]
  end

  def test_match_route_doesnt_match
    @router.draw do
      match "/foo"
      match "/bar"
    end

    refute @router.match_route("PATH_INFO" => "/not/found")
  end
end
