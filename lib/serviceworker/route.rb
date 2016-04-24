module ServiceWorker
  class Route
    attr_reader :path, :options

    def initialize(path, options = {})
      @path = path
      @options = options

      @pattern = compile(path)
    end

    def match?(path)
      @pattern =~ path
    end

    def asset_name
      @options.fetch(:asset, @path.gsub(%r{^/}, ""))
    rescue NoMethodError
      raise RouteError, "Cannot determine asset name from #{path.inspect}. Please specify the :asset option for this path."
    end

    def headers
      @options.fetch(:headers, {})
    end

    private

    def compile(path)
      if path.respond_to?(:to_str)
        special_chars = %w[. + ( )]
        pattern = path.to_str.gsub(/([\*#{special_chars.join}])/) do |match|
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
      elsif path.respond_to?(:match)
        path
      else
        raise TypeError, path
      end
    end
  end
end
