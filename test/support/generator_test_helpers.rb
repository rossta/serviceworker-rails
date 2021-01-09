# frozen_string_literal: true

module GeneratorTestHelpers
  FIXTURE_DIR = "fixtures"
  FIXTURE_WEBPACKER_DEFAULT_APP_JS = "webpacker_default_application.js"

  WEBPACKER_RAILS_TEMP_DIR = "tmp_wp"
  SPROCKETS_RAILS_TEMP_DIR = "tmp_sp"

  def self.included(base)
    base.extend ClassMethods
  end

  def evaluate_erb_asset_template(template)
    engine = ::ERB.new(template)
    asset_binding = asset_context_class.new.context_binding
    engine.result(asset_binding)
  end

  def asset_context_class
    Class.new do
      def image_path(name)
        "/assets/#{name}"
      end

      def context_binding
        binding
      end
    end
  end

  module ClassMethods
    def test_path
      File.join(File.dirname(__FILE__), "..")
    end

    def create_generator_sample_app
      # binding.pry
      FileUtils.cd(test_path) do
        # webpacker app gen
        system "rails new #{WEBPACKER_RAILS_TEMP_DIR} --skip-active-record --skip-test-unit --skip-spring --skip-bundle --quiet"
        system "sed -i -e '/bootsnap/d' #{WEBPACKER_RAILS_TEMP_DIR}/config/boot.rb"
        FileUtils.mkdir_p "#{WEBPACKER_RAILS_TEMP_DIR}/app/javascript/packs/"
        FileUtils.cp "#{FIXTURE_DIR}/#{FIXTURE_WEBPACKER_DEFAULT_APP_JS}", "#{WEBPACKER_RAILS_TEMP_DIR}/app/javascript/packs/application.js"

        # sprockets app gen
        system "rails new #{SPROCKETS_RAILS_TEMP_DIR} --skip-active-record --skip-test-unit --skip-spring --skip-bundle --quiet"
      end
    end

    def remove_generator_sample_app
      FileUtils.rm_rf("#{test_path}/#{WEBPACKER_RAILS_TEMP_DIR}")
      FileUtils.rm_rf("#{test_path}/#{SPROCKETS_RAILS_TEMP_DIR}")
    end
  end
end
