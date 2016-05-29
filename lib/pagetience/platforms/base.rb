module Pagetience
  module ElementPlatforms
    class Base
      attr_reader :browser

      class << self
        def find(klazz)
          valid_ancestor = ANCESTORS.find { |a| a.present? klazz }
          if valid_ancestor
            valid_ancestor.new klazz
          end
        end
      end

      def initialize(*args)
        @browser = nil
      end

      def platform_initialize(*args); end

      def underlying_element_for(sym)
        nil
      end

      def is_element_present?(sym)
        false
      end
    end
  end
end