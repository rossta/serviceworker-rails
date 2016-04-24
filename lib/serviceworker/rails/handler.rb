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
        @file_server ||= ::Rack::File.new(::Rails.root.join("public"))
      end

      def config
        ::Rails.configuration.assets
      end

      def asset_path(path)
        ::ActionController::Base.helpers.asset_path(path)
      end
    end
  end
end
