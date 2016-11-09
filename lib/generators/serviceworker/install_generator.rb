require "rails/generators"

module Serviceworker
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Make your Rails app a progressive web app"
      source_root File.join(File.dirname(__FILE__), "templates")

      def create_assets
        template "serviceworker.js",
          File.join(javascripts_base_dir, "serviceworker.js")
        template "serviceworker-companion.js",
          File.join(javascripts_base_dir, "serviceworker-companion.js")
        template "manifest.json",
          File.join(javascripts_base_dir, "manifest.json")
      end

      def create_initializer
        template "serviceworker.rb",
          File.join(initializers_dir, "serviceworker.rb")
      end

      def update_application_js
        ext, directive = detect_js_format
        append_to_file application_js_path(ext), "#{directive} require serviceworker-companion\n"
      end

      def update_precompiled_assets
        append_to_file File.join(initializers_dir, "assets.rb"),
          "Rails.configuration.assets.precompile += %w[serviceworker.js]\n"
      end

      def update_application_layout
        insert_into_file detect_layout,
          %(<link rel="manifest" href="/manifest.json" />),
          before: "</head>\n"
      end

      private

      def application_js_path(ext)
        File.join(javascripts_base_dir, "application#{ext}")
      end

      def detect_js_format
        %w[.coffee .coffee.erb .js.coffee .js.coffee.erb .js .js.erb].each do |ext|
          next unless File.exist?(File.join(javascripts_base_dir, "application#{ext}"))
          return [ext, "#="] if ext.include?(".coffee")
          return [ext, "//="]
        end
      end

      def detect_layout
        layouts = %w[.html.erb .html.haml .html.slim].map do |ext|
          File.join(layouts_base_dir, "application#{ext}")
        end
        layouts.find { |layout| File.exist?(layout) }
      end

      def javascripts_base_dir
        File.join("app", "assets", "javascripts")
      end

      def initializers_dir
        File.join("config", "initializers")
      end

      def layouts_base_dir
        File.join("app", "views", "layouts")
      end
    end
  end
end
