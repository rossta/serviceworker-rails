# frozen_string_literal: true
module ServiceWorker
  class Middleware
    REQUEST_METHOD = "REQUEST_METHOD".freeze
    GET = "GET".freeze
    HEAD = "HEAD".freeze

    # Initialize the Rack middleware for responding to serviceworker asset
    # requests
    #
    # @app [#call] middleware stack
    # @opts [Hash] options to inject
    # @param opts [#match_route] :routes matches routes on PATH_INFO
    # @param opts [Hash] :headers default headers to use for matched routes
    # @param opts [#call] :handler resolves response from matched asset name
    # @param opts [#info] :logger logs requests
    def initialize(app, opts = {})
      @app = app
      @opts = opts
      @headers = opts.fetch(:headers, {}).merge(default_headers)
      @router = opts.fetch(:routes, ServiceWorker::Router.new)
      @handler = @opts.fetch(:handler, default_handler)
    end

    def call(env)
      case env[REQUEST_METHOD]
        when GET, HEAD
        route_match = @router.match_route(env)
        return respond_to_match(route_match, env) if route_match
      end

      @app.call(env)
    end

  private

    def default_headers
      {
        "Cache-Control" => "private, max-age=0, no-cache"
      }
    end

    def respond_to_match(route_match, env)
      env = env.merge("serviceworker.asset_name" => route_match.asset_name)

      status, headers, body = @handler.call(env)

      [status, headers.merge(@headers).merge(route_match.headers), body]
    end

    def info(msg)
      logger.info "[#{self.class}] - #{msg}"
    end

    def logger
      @logger ||= @opts.fetch(:logger, Logger.new(STDOUT))
    end

    def default_handler
      require "serviceworker/handler"
      ServiceWorker::Handler.new
    end
  end
end
