module Pagetience
  module Platform
    class PageObjectGem
      class << self
        def init(base, *args)
          args.flatten! if args

          base.class.send(:define_method, :visit) do
            args[1] || false
          end
          base.instance_eval do
            PageObject.instance_method(:initialize).bind(self).call(base.browser, visit)
          end

          self.new base
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