require "test_helper"

class ServiceWorker::RouteTest < Minitest::Test
  def new_route(*args)
    ServiceWorker::Route.new(*args)
  end

  def test_initialize_route
    route = new_route("/path", { foo: "bar" })

    assert_equal route.path, "/path"
    assert_equal route.options, { foo: "bar" }
  end

  def test_path_match_string
    route = new_route("/path")

    assert route.match?("/path")
    refute route.match?("/dont")
  end

  def test_path_match_wildcard_string
    route = new_route("/*/path")

    assert route.match?("/foo/path"), "Should match /foo/path"
    assert route.match?("/foo/bar/path"), "Should not match /foo/bar/path"
    refute route.match?("/foo/bar"), "Should not match /foo/bar"
  end

  def test_path_match_regex
    route = new_route(%r{^/ball?oo?n?s?})

    assert route.match?("/balloon"), "Should match /balloon"
    assert route.match?("/ballon"), "Should match /ballon"
    assert route.match?("/baloon"), "Should match /baloon"
    assert route.match?("/balloons"), "Should match /balloons"
    refute route.match?("/boos"), "Should not match /boos"
    refute route.match?("/no/balloons"), "Should not match /no/balloons"
    refute route.match?("/marbles"), "Should not match /marbles"
  end

  def test_asset_name_default
    route = new_route("/path")

    assert_equal route.asset_name, "path"
  end

  def test_asset_from_option
    route = new_route("/path", asset: "foobar")

    assert_equal route.asset_name, "foobar"
  end

  def test_asset_from_path_regex
    route = new_route(%r{^/path})

    assert_raises ServiceWorker::RouteError do
      route.asset_name
    end
  end
end
