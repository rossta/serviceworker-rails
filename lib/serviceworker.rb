module ServiceWorker
  class << self
    # The path to the root of the application. ServiceWorker.rb uses this property
    # to . If you are using ServiceWorker.rb with Rails, you do not need to set
    # this attribute manually.
    #
    # @return [String]
    attr_accessor :root

    # The logger to use when logging exception details and backtraces. If you
    # are using Better Errors with Rails, you do not need to set this attribute
    # manually. If this attribute is `nil`, nothing will be logged.
    #
    # @return [Logger, nil]
    attr_accessor :logger
  end
end

require "serviceworker/middleware"
