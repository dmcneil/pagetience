module Pagetience
  module ElementPlatforms
    class PageObjectGem < Base
      attr_reader :page_object_instance

      class << self
        def present?(klazz)
          klazz.class.ancestors.include? PageObject
        end
      end

      def initialize(klazz)
        super

        @page_object_instance = klazz
        @browser = @page_object_instance.browser
      end

      # TODO
      def platform_initialize
        @page_object_instance.instance_eval do
          PageObject.instance_method(:initialize).bind(self).call(@browser)
        end
      end

      def underlying_element_for(sym)
        @page_object_instance.send("#{sym}_element").element
      end
    end
  end
end