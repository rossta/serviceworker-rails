# frozen_string_literal: true
require "rack/file"

module ServiceWorker
  module Rails
    class Handler
      def call(env)
        path_info = env.fetch("serviceworker.asset_name")

        if config.compile
          sprockets_server.call(env.merge("PATH_INFO" => path_info))
        else
          file_server.call(env.merge("PATH_INFO" => asset_path(path_info)))
        end
      end

    private

      def sprockets_server
        ::Rails.application.assets
      end

      def file_server
        @file_server ||= ::Rack::File.new(::Rails.public_path)
      end

      def config
        ::Rails.configuration.assets
      end

      def asset_path(path)
        if controller_helpers.respond_to?(:compute_asset_path)
          controller_helpers.compute_asset_path(path)
        else
          controller_helpers.asset_path(path, host: proc {})
        end
      end

      def controller_helpers
        ::ActionController::Base.helpers
      end
    end
  end
end
