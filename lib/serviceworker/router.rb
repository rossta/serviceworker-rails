# frozen_string_literal: true
module ServiceWorker
  class Router
    PATH_INFO = "PATH_INFO".freeze

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

    def match(path, options = {})
      Route.new(path, options).tap do |route|
        @routes << route
      end
    end
    alias get match

    def any?
      @routes.any?
    end

    def match_route(env)
      path = env[PATH_INFO]
      @routes.each do |route|
        if match = route.match(path)
          return match
        end
      end
      nil
    end
  end
end
