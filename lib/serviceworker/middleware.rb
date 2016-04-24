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
      status, headers, body = process_handler(route, env)

      [status, headers.merge(@headers).merge(route.headers), body]
    end

    def process_handler(route, env)
      handler.call(env.merge("serviceworker.asset_name" => route.asset_name))
    end

    def info(msg)
      logger.info "[#{self.class}] - #{msg}"
    end

    def handler
      @handler ||= @opts.fetch(:handler, ServiceWorker::Rails::Handler.new)
    end

    def logger
      @logger ||= @opts.fetch(:logger, Logger.new(STDOUT))
    end
  end
end
