require 'pagetience'

module Pagetience
  module DSL
    def current_page
      @browser.current_page
    end
  end
end