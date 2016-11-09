require "rails_helper"
require "fileutils"

module GeneratorTestHelpers
  def create_generator_sample_app
    FileUtils.mkdir_p(tmp_path)
    FileUtils.cd(tmp_path) do
      system "rails new generator_sample --skip-active-record --skip-test-unit --skip-spring --skip-bundle --quiet"
      File.open(File.join(sample_app_path, "Gemfile"), "a") do |f|
        f.puts "gem 'serviceworker-rails', path: '#{File.join(File.dirname(__FILE__), "..", "..")}'"
      end
    end

    FileUtils.cd(sample_app_path) do
      system "bundle install --quiet"
    end
  end

  def install_serviceworker_rails
    FileUtils.cd(sample_app_path) do
      system "rails g serviceworker:install --quiet -f 2>&1"
    end
  end

  def remove_generator_sample_app
    FileUtils.rm_rf(tmp_path)
  end

  def sample_app_path
    File.join(tmp_path, "generator_sample")
  end

  def tmp_path
    File.join(File.dirname(__FILE__), "..", "tmp")
  end
end

class ServiceWorker::GeneratorTest < Minitest::Test
  include GeneratorTestHelpers
  extend GeneratorTestHelpers

  create_generator_sample_app
  install_serviceworker_rails

  Minitest.after_run do
    remove_generator_sample_app
  end

  def test_generates_serviceworker
    serviceworker_js = File.read("#{sample_app_path}/app/assets/javascripts/serviceworker.js")
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
    manifest_json = File.read("#{sample_app_path}/app/assets/javascripts/manifest.json")

    assert manifest_json =~ /"name": "My Progressive Rails App"/,
      "Expected manifest to be generated"
  end

  def test_appends_precompilation
    precompilation_rb = File.read("#{sample_app_path}/config/initializers/assets.rb")

    assert precompilation_rb =~ /Rails.configuration.assets.precompile \+\= \%w\[serviceworker.js\]/,
      "Expected asset to be precompiled"
  end

  def test_appends_companion_require
    application_js = File.read("#{sample_app_path}/app/assets/javascripts/application.js")

    assert application_js =~ %r{\n\/\/= require serviceworker-companion},
      "Expected companion to be required"
  end

  def test_appends_manifest_link
    application_layout = File.read("#{sample_app_path}/app/views/layouts/application.html.erb")

    assert application_layout =~ %r{\<link rel="manifest" href="/manifest.json" \/\>},
      "Expected manifest to be linked"
  end
end
