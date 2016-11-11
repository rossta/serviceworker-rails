require "rails_helper"
require "fileutils"

class ServiceWorker::GeneratorTest < Minitest::Test
  include GeneratorTestHelpers

  # Run once, i.e., before(:all)
  create_generator_sample_app
  install_serviceworker_rails

  Minitest.after_run do
    remove_generator_sample_app
  end

  def test_generates_serviceworker
    serviceworker_js = File.read("#{sample_app_path}/app/assets/javascripts/serviceworker.js.erb")
    companion_js = File.read("#{sample_app_path}/app/assets/javascripts/serviceworker-companion.js")

    assert serviceworker_js =~ /self.addEventListener\('install', onInstall\)/,
      "Expected serviceworker to be generated"
    assert companion_js =~ /navigator.serviceWorker.register/,
      "Expected serviceworker companion to be generated"
  end

  def test_generates_initializer
    initializer_rb = File.read("#{sample_app_path}/config/initializers/serviceworker.rb")

    assert initializer_rb =~ /config.serviceworker.routes.draw/,
      "Expected initializer to be generated"
  end

  def test_generates_manifest
    manifest_template = File.read("#{sample_app_path}/app/assets/javascripts/manifest.json.erb")

    assert manifest_template =~ /"name": "My Progressive Rails App"/,
      "Expected manifest to be generated"

    manifest_json = JSON.parse(evaluate_erb_asset_template(manifest_template))

    assert_equal manifest_json["name"], "My Progressive Rails App"
    assert_equal manifest_json["icons"].length, ::Rails.configuration.serviceworker.icon_sizes.length
  end

  def test_appends_precompilation
    precompilation_rb = File.read("#{sample_app_path}/config/initializers/assets.rb")

    assert precompilation_rb =~ /Rails.configuration.assets.precompile \+\= \%w\[serviceworker.js manifest.json\]/,
      "Expected assets to be precompiled"
  end

  def test_appends_companion_require
    application_js = File.read("#{sample_app_path}/app/assets/javascripts/application.js")

    assert application_js =~ %r{\n\/\/= require serviceworker-companion},
      "Expected companion to be required"
  end

  def test_appends_manifest_link
    application_layout = File.read("#{sample_app_path}/app/views/layouts/application.html.erb")

    assert application_layout =~ %r{<link rel="manifest" href="/manifest.json" />},
      "Expected manifest to be linked"
    assert application_layout =~ /<meta name="apple-mobile-web-app-capable" content="yes">/,
      "Expected apple meta tag"
  end

  def test_generates_offline_html
    assert File.exist?("#{sample_app_path}/public/offline.html"), "Expected offline.html to be generated"
  end
end
