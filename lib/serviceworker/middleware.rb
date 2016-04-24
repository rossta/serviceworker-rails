module ServiceWorker
  class Middleware
    def initialize(app, opts = {})
      @app = app
      @opts = opts
      @headers = opts.fetch(:headers, {}).merge(default_headers)
      @router = opts.fetch(:routes, ServiceWorker::Router.default)
    end

    def call(env)
      case env["REQUEST_METHOD"]
      when "GET", "HEAD"
        path = env["PATH_INFO"].chomp("/")
        info("responding to #{path}")
        route = @router.match_route(path)
        return respond_to_route(route, env) if route
      end

      @app.call(env)
    end

    private

    def default_headers
      {
        "Cache-Control" => "private, max-age=0, no-cache"
      }
    end

    def respond_to_route(route, env)
      status, headers, body = handle_route(route, env)

      [status, headers.merge(@headers).merge(route.headers), body]
    end

    def handle_route(route, env)
      if config.compile
        sprockets_server.call(env.merge("PATH_INFO" => route.asset_name))
      else
        file_path = asset_path(route.asset_name)
        file_server.call(env.merge("PATH_INFO" => file_path))
      end
    end

    def info(msg)
      logger.info "[#{self.class}] - #{msg}"
    end

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

    def logger
      @logger ||= @opts.fetch(:logger, Logger.new(STDOUT))
    end
  end
end
