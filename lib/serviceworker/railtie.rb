require "rails"
require "rails/railtie"
require "serviceworker"

module ServiceWorker
  class Railtie < ::Rails::Railtie
    config.serviceworker = ActiveSupport::OrderedOptions.new
    config.serviceworker.headers = {}
    config.serviceworker.routes = ServiceWorker::Router.new
    config.serviceworker.handler = ServiceWorker::Rails::Handler.new

    initializer "serviceworker-rails.configure_rails_initialization", after: :load_config_initializers do
      config.serviceworker.logger ||= ::Rails.logger

      app.middleware.use ServiceWorker::Middleware, config.serviceworker
    end

    def app
      ::Rails.application
    end
  end
end
