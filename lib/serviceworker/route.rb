module ServiceWorker
  class Route
    attr_reader :path_pattern, :asset_pattern, :options

    RouteMatch = Struct.new(:path, :asset_name, :headers) do
      def to_s
        asset_name
      end
    end

    def initialize(path_pattern, asset_pattern = nil, options = {})
      if asset_pattern.is_a?(Hash)
        options = asset_pattern
        asset_pattern = nil
      end

      @path_pattern = path_pattern
      @asset_pattern = asset_pattern || options[:asset] || path_pattern
      @options = options
    end

    def match(path)
      if path.to_s.strip.empty?
        raise ArgumentError.new("path is required")
      end

      asset = resolver.call(path) or return nil

      RouteMatch.new(path, asset, headers)
    end

    def headers
      @options.fetch(:headers, {})
    end

    private

    def resolver
      @resolver ||= AssetResolver.new(path_pattern, asset_pattern)
    end

    class AssetResolver
      PATH_INFO = 'PATH_INFO'.freeze
      DEFAULT_WILDCARD_NAME = :paths
      WILDCARD_PATTERN = /\/\*([^\/]*)/.freeze
      NAMED_SEGMENTS_PATTERN = /\/([^\/]*):([^:$\/]+)/.freeze
      LEADING_SLASH_PATTERN = /^\//
      INTERPOLATION_PATTERN = Regexp.union(
        /%%/,
        /%\{(\w+)\}/, # matches placeholders like "%{foo}"
      )

      attr_reader :path_pattern, :asset_pattern

      def initialize(path_pattern, asset_pattern)
        @path_pattern = path_pattern
        @asset_pattern = asset_pattern
      end

      def call(path)
        if path.to_s.strip.empty?
          raise ArgumentError.new("path is required")
        end

        captures = path_captures(regexp, path) or return nil

        interpolate_captures(asset_pattern, captures)
      end

      private

      def regexp
        @regexp ||= compile_regexp(path_pattern)
      end

      def compile_regexp(pattern)
        Regexp.new("\\A#{compiled_source(pattern)}\\Z")
      end

      def compiled_source(pattern)
        if pattern_match = pattern.match(WILDCARD_PATTERN)
          @wildcard_name = if pattern_match[1].to_s.strip.empty?
                             DEFAULT_WILDCARD_NAME
                           else
                             pattern_match[1].to_sym
                           end
          pattern.gsub(WILDCARD_PATTERN,'(?:/(.*)|)')
        else
          p = if pattern_match = pattern.match(NAMED_SEGMENTS_PATTERN)
                pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^.$/]+)')
              else
                pattern
              end
          p + '(?:\.(?<format>.*))?'
        end
      end

      def path_captures(regexp, path)
        return nil unless path_match = path.match(regexp)
        params = if @wildcard_name
                   { @wildcard_name => path_match[1].to_s.split('/') }
                 else
                   Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
                 end
        params.delete(:format) if params.has_key?(:format) && params[:format].nil?
        params
      end

      def interpolate_captures(string, captures)
        string.gsub(INTERPOLATION_PATTERN) do |match|
          if match == '%%'
            '%'
          else
            key = ($1 || $2).to_sym
            value = if captures.key?(key)
                      Array(captures[key]).join("/")
                    else
                      raise "Interpolation error: #{key} not captured in #{captures.inspect}"
                    end
            value = value.call(captures) if value.respond_to?(:call)
            $3 ? sprintf("%#{$3}", value) : value
          end
        end.gsub(LEADING_SLASH_PATTERN, "")
      end
    end
  end
end
