module ServiceWorker
  class Router
    def self.default
      new.draw_default
    end

    attr_reader :routes

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

    def draw_default
      draw { get "/serviceworker.js" }
    end

    def get(path, options = {})
      Route.new(path, options).tap do |route|
        @routes << route
      end
    end

    def any?
      @routes.any?
    end

    def match_route(path)
      @routes.detect { |r| r.match?(path) }
    end
  end

end
