module Pagetience
  class Configuration
    VALID_PROPERTIES = [
        :timeout,
        :polling,
        :platform
    ]

    attr_accessor *VALID_PROPERTIES

    # Default timeout in seconds
    DEFAULT_TIMEOUT = 30

    # Default polling in seconds
    DEFAULT_POLLING = 1

    # Default element platform
    DEFAULT_PLATFORM = Pagetience::Platform::PageObjectGem

    def initialize
      @timeout = DEFAULT_TIMEOUT
      @polling = DEFAULT_POLLING
      @platform = DEFAULT_PLATFORM
    end

    def method_missing(sym, *args)
      raise Pagetience::ConfigurationError, "Unknown property #{sym}."
    end
  end
end
