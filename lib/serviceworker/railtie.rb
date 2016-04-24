require "rails"
require "rails/railtie"
require "pry"

module ServiceWorker
  class Railtie < ::Rails::Railtie
    config.serviceworker = ActiveSupport::OrderedOptions.new
    config.serviceworker.headers = {}
    config.serviceworker.routes = ServiceWorker::Router.new

    initializer "serviceworker-rails.configure_rails_initialization" do
      config.serviceworker.logger ||= ::Rails.logger
      app.middleware.use ServiceWorker::Middleware, config.serviceworker
    end

    def app
      ::Rails.application
    end
  end
end
