module Pagetience
  module Platforms
    class Base
      attr_reader :browser

      def initialize(*args)
        @browser = nil
      end

      def platform_initialize; end

      def is_browser?
        false
      end

      def underlying_element_for(sym)
        nil
      end
    end
  end
end