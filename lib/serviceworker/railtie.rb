require "rails"
require "rails/railtie"
require "pry"

module ServiceWorker
  class Railtie < ::Rails::Railtie
    config.serviceworker = ActiveSupport::OrderedOptions.new
    config.serviceworker.headers = {}

    initializer "serviceworker-rails.configure_rails_initialization" do
      config.serviceworker.logger ||= ::Rails.logger
      insert_middleware
    end

    def insert_middleware
      if defined? ::Rack::SendFile
        app.middleware.insert_after ::Rack::Sendfile, ServiceWorker::Middleware, config.serviceworker
      else
        app.middleware.use ServiceWorker::Middleware, config.serviceworker
      end
    end

    def app
      ::Rails.application
    end
  end
end
