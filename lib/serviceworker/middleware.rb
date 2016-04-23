module ServiceWorker
  class Middleware
    def initialize(app, logger: ServiceWorker.logger)
      @app = app
      @logger = logger
    end

    def call(env)
      case env['REQUEST_METHOD']
      when 'GET', 'HEAD'
        path = env['PATH_INFO'].chomp('/')
        return respond_to(path, env) if match?(path)
      end

      @app.call(env)
    end

    def match?(path)
      path == '/serviceworker.js'
    end

    private

    def respond_to(path_info, env)
      if config.compile
        info "Compiling #{path_info} from Sprockets"
        sprockets_server.call(env)
      else
        file_path = asset_path(path_info)
        info "Proxing #{path_info} from #{file_path}"
        file_server.call(env.merge('PATH_INFO' => file_path))
      end
    end

    def info(msg)
      @logger.info "[#{self.class}] - #{msg}"
    end

    def sprockets_server
      ::Rails.application.assets
    end

    def file_server
      @file_server ||= ::Rack::File.new(::Rails.root.join("public"))
    end

    def config
      ::Rails.application.config.assets
    end

    def asset_path(path)
      ::ActionController::Base.helpers.asset_path(path.gsub(/^\//, ''))
    end
  end
end
