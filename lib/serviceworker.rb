module ServiceWorker
  class Router
    def self.default
      new do
        get "/serviceworker.js"
      end
    end

    def initialize
      @routes = []

      draw(&Proc.new) if block_given?
    end

    def draw(&block)
      return self unless block_given?

      if block.arity == 1
        block.call(self)
      else
        instance_eval(&block)
      end

      self
    end

    def get(path, options = {})
      @routes << Route.new(path, options)
    end

    def match_route(path)
      @routes.detect { |r| r.match?(path) }
    end
  end

  class Route
    def initialize(path, options)
      @path = path
      @options = options

      @pattern = compile(path)
    end

    def match?(path)
      @pattern =~ path
    end

    def asset_name
      @options.fetch(:asset, @path.gsub(%r{^/}, ""))
    end

    def headers
      @options.fetch(:headers, {})
    end

    private

    def compile(path)
      if path.respond_to? :to_str
        special_chars = %w{. + ( )}
        pattern =
          path.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
            case match
            when "*"
              "(.*?)"
            when *special_chars
              Regexp.escape(match)
            else
              "([^/?&#]+)"
            end
          end
        /^#{pattern}$/
      elsif path.respond_to? :match
        path
      else
        raise TypeError, path
      end
    end
  end
end

require "serviceworker/middleware"
