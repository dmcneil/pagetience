require 'pagetience'

module Pagetience
  module DSL
    def current_page
      @browser.current_page
    end

    def wait_for_element(sym)
      @browser.current_page.wait_for_element sym
    end
  end
end