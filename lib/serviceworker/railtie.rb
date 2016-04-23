require "rails"
require "rails/railtie"

module ServiceWorker
  class Railtie < ::Rails::Railtie
    initializer "serviceworker-rails.configure_rails_initialization" do
      insert_middleware
      ServiceWorker.logger = ::Rails.logger
      ServiceWorker.root = ::Rails.root.to_s
    end

    def insert_middleware
      if defined? ::Rack::SendFile
        app.middleware.insert_after ::Rack::Sendfile, ServiceWorker::Middleware
      else
        app.middleware.use ServiceWorker::Middleware
      end
    end

    def app
      ::Rails.application
    end
  end
end
