module Pagetience
  class Timer
    attr_accessor :timeout, :polling, :block

    def initialize(timeout=30, polling=1, &block)
      @timeout = timeout
      @polling = polling
      @block = block
    end

    def run_until(expected=nil)
      raise ArgumentError, 'Timeout cannot be lower than the polling value.' unless @timeout > @polling

      while @timeout > 0 && @timeout > @polling
        @latest_result = @block.call
        break unless expected && @latest_result != expected
        sleep @polling
        @timeout = @timeout - @polling
      end

      @latest_result
    end
    alias_method :run, :run_until
  end
end