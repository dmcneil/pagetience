module Pagetience
  module Platform
    class PageObjectGem
      class << self
        def init(*args)
          page = args[0][:page]
          page.class.send(:define_method, :visit) do
            args[0][:args][1] || false
          end
          page.instance_eval do
            PageObject.instance_method(:initialize).bind(self).call(page.browser, visit)
          end

          self.new page
        end
      end

      attr_reader :page_object, :browser

      def initialize(page)
        @page_object = page
        @browser = @page_object.browser
      end

      def underlying_element_for(sym)
        @page_object.send("#{sym}_element").element
      end

      def is_element_present?(sym)
        @page_object.send("#{sym}_element").visible?
      end
    end
  end
end