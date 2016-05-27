module Pagetience
  class Meditate
    DEFAULT_TIMEOUT_MESSAGE = 'Timed out waiting for the expected result.'

    attr_accessor :timeout, :polling, :block

    class << self
      def for(opts, &block)
        opts[:timeout] ||= 30
        opts[:polling] ||= 1
        opts[:msg] ||= DEFAULT_TIMEOUT_MESSAGE
        Meditate.new(opts[:timeout], opts[:polling]) { block.call }.until_enlightened opts[:expecting], opts[:msg]
      end
    end

    def initialize(timeout=30, polling=1, &block)
      @timeout = timeout
      @polling = polling
      @block = block
    end

    def until_enlightened(expected=nil, msg=DEFAULT_TIMEOUT_MESSAGE)
      raise ArgumentError, 'Timeout cannot be lower than the polling value.' unless @timeout > @polling

      while @timeout > 0 && @timeout > @polling
        @latest_result = @block.call
        break if @latest_result == expected
        sleep @polling
        @timeout = @timeout - @polling
      end

      raise Pagetience::Exceptions::Timeout, msg unless @latest_result == expected

      @latest_result
    end
  end
end