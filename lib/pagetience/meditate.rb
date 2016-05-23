module Pagetience
  class Meditate
    attr_accessor :timeout, :polling, :block

    def initialize(timeout=30, polling=1, &block)
      @timeout = timeout
      @polling = polling
      @block = block
    end

    def until_enlightened(expected=nil, msg='Timed out waiting for the expected result.')
      raise ArgumentError, 'Timeout cannot be lower than the polling value.' unless @timeout > @polling

      while @timeout > 0 && @timeout > @polling
        @latest_result = @block.call
        break unless expected && @latest_result != expected
        sleep @polling
        @timeout = @timeout - @polling
      end

      raise Pagetience::Exceptions::Timeout, msg unless @latest_result

      @latest_result
    end
  end
end