require "serviceworker/handlers/rack_handler"
require "serviceworker/handlers/sprockets_handler"

module ServiceWorker
  module Handlers
    extend self

    def build(handler)
      return handler if handler.respond_to?(:call)
      default_handler
    end

    def route_match_handler(route_match)
      return webpacker_handler if route_match.options[:pack] && webpacker?
      nil
    end

    def webpacker_handler
      require "serviceworker/handlers/webpacker_handler"
      ServiceWorker::Handlers::WebpackerHandler.new
    end

    def default_handler
      if sprockets?
        ServiceWorker::Handlers::SprocketsHandler.new
      else
        ServiceWorker::Handlers::RackHandler.new
      end
    end

    def webpacker?
      defined?(::Webpacker)
    end

    def sprockets?
      defined?(::Rails) && ::Rails.configuration.assets
    end
  end
end
