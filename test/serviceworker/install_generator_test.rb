# frozen_string_literal: true

require "test_helper"
require "generators/serviceworker/install_generator"

class ServiceWorker::InstallGeneratorTestInfra < ::Rails::Generators::TestCase
  include GeneratorTestHelpers

  class_attribute :install_destination

  tests Serviceworker::Generators::InstallGenerator

  remove_generator_sample_app
  create_generator_sample_app

  Minitest.after_run do
    remove_generator_sample_app
  end
end

class ServiceWorker::InstallGeneratorSprocketsTest < ServiceWorker::InstallGeneratorTestInfra
  destination File.expand_path("../#{SPROCKETS_RAILS_TEMP_DIR}", File.dirname(__FILE__))

  setup do
    run_generator
  end

  test "generates serviceworker" do
    assert_file "app/assets/javascripts/serviceworker.js.erb" do |content|
      assert_match(/self.addEventListener\('install', onInstall\)/, content)
    end
  end

  test "generates web app manifest" do
    assert_file "app/assets/javascripts/manifest.json.erb" do |content|
      assert_match(/"name": "My Progressive Rails App"/, content)

      json = JSON.parse(evaluate_erb_asset_template(content))

      assert_equal json["name"], "My Progressive Rails App"
      assert_equal json["icons"].length, ::Rails.configuration.serviceworker.icon_sizes.length
    end
  end

  test "generates companion javascript" do
    assert_file "app/assets/javascripts/serviceworker-companion.js" do |content|
      assert_match(/navigator.serviceWorker./, content)
    end

    assert_file "app/assets/javascripts/application.js" do |content|
      assert_match(%r{\n//= require serviceworker-companion}, content)
    end
  end

  test "generates initializer and precompiles assets" do
    assert_file "config/initializers/serviceworker.rb" do |content|
      assert_match(/config.serviceworker.routes.draw/, content)
    end

    assert_file "config/initializers/assets.rb" do |content|
      matcher = /Rails.configuration.assets.precompile \+= %w\[serviceworker.js manifest.json\]/
      assert_match(matcher, content)
    end
  end

  test "appends manifest link" do
    assert_file "app/views/layouts/application.html.erb" do |content|
      assert_match(%r{<link rel="manifest" href="/manifest.json" />}, content)
      assert_match(/<meta name="apple-mobile-web-app-capable" content="yes">/, content)
    end
  end

  test "generates offline html" do
    assert_file "public/offline.html"
  end

  test "missing application layout does not error" do
    dir = File.expand_path("../#{SPROCKETS_RAILS_TEMP_DIR}", File.dirname(__FILE__))
    system "mv #{dir}/app/views/layouts/application.html.erb #{dir}/app/views/layouts/application.tmp"
    run_generator
    system "mv #{dir}/app/views/layouts/application.tmp #{dir}/app/views/layouts/application.html.erb"
  end
end

class ServiceWorker::InstallGeneratorWebpackerTest < ServiceWorker::InstallGeneratorTestInfra
  destination File.expand_path("../#{WEBPACKER_RAILS_TEMP_DIR}", File.dirname(__FILE__))

  setup do
    run_generator ["--webpacker"]
  end

  test "generates serviceworker" do
    assert_file "app/javascript/packs/serviceworker.js.erb" do |content|
      assert_match(/self.addEventListener\('install', onInstall\)/, content)
    end
  end

  test "generates web app manifest" do
    assert_file "app/javascript/packs/manifest.json.erb" do |content|
      assert_match(/"name": "My Progressive Rails App"/, content)

      json = JSON.parse(evaluate_erb_asset_template(content))

      assert_equal json["name"], "My Progressive Rails App"
      assert_equal json["icons"].length, ::Rails.configuration.serviceworker.icon_sizes.length
    end
  end

  test "generates companion javascript" do
    assert_file "app/javascript/packs/serviceworker-companion.js" do |content|
      assert_match(/navigator.serviceWorker./, content)
    end

    assert_file "app/javascript/packs/application.js" do |content|
      assert_match(%r{\nrequire\("\./serviceworker-companion"\);}, content)
    end
  end

  test "appends manifest link" do
    assert_file "app/views/layouts/application.html.erb" do |content|
      assert_match(%r{<link rel="manifest" href="/manifest.json" />}, content)
      assert_match(/<meta name="apple-mobile-web-app-capable" content="yes">/, content)
    end
  end

  test "generates offline html" do
    assert_file "public/offline.html"
  end

  test "missing application layout does not error" do
    dir = File.expand_path("../#{WEBPACKER_RAILS_TEMP_DIR}", File.dirname(__FILE__))
    system "mv #{dir}/app/views/layouts/application.html.erb #{dir}/app/views/layouts/application.tmp"
    run_generator ["--webpacker"]
    system "mv #{dir}/app/views/layouts/application.tmp #{dir}/app/views/layouts/application.html.erb"
  end
end
