# frozen_string_literal: true

require "rack/file"
require "webpacker"

module ServiceWorker
  module Rails
    class WebpackerHandler
      def call(env)
        path_info = env.fetch("serviceworker.asset_name")

        path = Webpacker.manifest.lookup(path_info)

        file_server.call(env.merge("PATH_INFO" => path))
      end

      private

      def file_server
        @file_server ||= ::Rack::File.new(::Rails.public_path)
      end
    end
  end
end
