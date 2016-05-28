require 'spec_helper'

require 'pagetience/dsl'

class FirstPage
  include PageObject
  include Pagetience
end

class SecondPage < FirstPage; end

describe Pagetience::DSL do
  let(:browser) { mock_watir_browser }
  let(:page) { FirstPage.new(browser) }

  include Pagetience::DSL

  describe '.current_page' do
    it 'returns the current page' do
      allow(browser).to receive(:current_page).and_return(page)
      @browser = browser

      expect(current_page).to be_a FirstPage
    end
  end
end