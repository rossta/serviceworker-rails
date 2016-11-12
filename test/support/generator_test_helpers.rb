module GeneratorTestHelpers
  def self.included(base)
    base.extend ClassMethods
  end

  def evaluate_erb_asset_template(template)
    engine = ::ERB.new(template)
    asset_binding = asset_context_class.new.instance_eval("binding")
    engine.result(asset_binding)
  end

  def asset_context_class
    Class.new do
      def image_path(name)
        "/assets/#{name}"
      end
    end
  end

  module ClassMethods
    def test_path
      File.join(File.dirname(__FILE__), "..")
    end

    def create_generator_sample_app
      FileUtils.cd(test_path) do
        system "rails new tmp --skip-active-record --skip-test-unit --skip-spring --skip-bundle --quiet"
      end
    end

    def remove_generator_sample_app
      FileUtils.rm_rf(destination_root)
    end
  end
end
