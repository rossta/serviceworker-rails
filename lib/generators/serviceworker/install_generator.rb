require "rails/generators"

module Serviceworker
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Make your Rails app a progressive web app"
      source_root File.join(File.dirname(__FILE__), "templates")

      def create_assets
        template "manifest.json", javascripts_dir("manifest.json")
        template "serviceworker.js", javascripts_dir("serviceworker.js")
        template "serviceworker-companion.js", javascripts_dir("serviceworker-companion.js")
      end

      def create_initializer
        template "serviceworker.rb", initializers_dir("serviceworker.rb")
      end

      def update_application_js
        ext, directive = detect_js_format
        snippet = "#{directive} require serviceworker-companion\n"
        append_to_file application_js_path(ext), snippet
      end

      def update_precompiled_assets
        snippet = "Rails.configuration.assets.precompile += %w[serviceworker.js]\n"
        append_to_file initializers_dir("assets.rb"), snippet
      end

      def update_application_layout
        snippet = %(<link rel="manifest" href="/manifest.json" />)
        snippet << %(\n<meta name="apple-mobile-web-app-capable" content="yes">)
        insert_into_file detect_layout, snippet, before: "</head>\n"
      end

      def add_offline_html
        template "offline.html", public_dir("offline.html")
      end

      private

      def application_js_path(ext)
        javascripts_dir("application#{ext}")
      end

      def detect_js_format
        %w[.coffee .coffee.erb .js.coffee .js.coffee.erb .js .js.erb].each do |ext|
          next unless File.exist?(javascripts_dir("application#{ext}"))
          return [ext, "#="] if ext.include?(".coffee")
          return [ext, "//="]
        end
      end

      def detect_layout
        layouts = %w[.html.erb .html.haml .html.slim].map do |ext|
          layouts_dir("application#{ext}")
        end
        layouts.find { |layout| File.exist?(layout) }
      end

      def javascripts_dir(*paths)
        File.join("app", "assets", "javascripts", *paths)
      end

      def initializers_dir(*paths)
        File.join("config", "initializers", *paths)
      end

      def layouts_dir(*paths)
        File.join("app", "views", "layouts", *paths)
      end

      def public_dir(*paths)
        File.join("public", *paths)
      end
    end
  end
end
