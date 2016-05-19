require 'sloth'
require 'page-object'
require 'watir-webdriver'

def mock_watir_browser
  watir_browser = double('watir')
  allow(watir_browser).to receive(:is_a?).with(anything()).and_return(false)
  allow(watir_browser).to receive(:is_a?).with(Watir::Browser).and_return(true)
  watir_browser
end

module Sloth
  context 'when included' do
    class SomePage
      include PageObject
      include Sloth

      button :foo, id: 'foo'
      required :foo
    end

    let(:browser) { mock_watir_browser }
    let(:page) { SomePage.new browser }

    it 'extends ClassMethods' do
      expect(SomePage.ancestors).to include Sloth::ClassMethods
    end

    describe '.wait_for' do
      it 'responds to' do
        expect(SomePage).to respond_to :wait_for
      end
    end

    describe '.required' do
      it 'responds to' do
        expect(SomePage).to respond_to :required
      end

      it 'creates .wait_for_required_elements' do
        expect(page).to respond_to :wait_for_required_elements
      end
    end
  end

  context 'when initialized' do
    let(:browser) { mock_watir_browser }

    class RandomPage
      include PageObject
      include Sloth

      button :foo, id: 'foo'
    end

    it 'lists ancestors' do
      RandomPage.new browser
    end
  end

  describe '.wait_for' do
    class SomePage
      include Sloth
    end

    it 'will wait for a truthy block' do
      calls = []
      truthy = false
      expect{ SomePage.wait_for(11, 3) { calls << truthy; truthy }}.to raise_error Sloth::Exceptions::Timeout
      expect(calls.size).to eq 3
      calls.each { |c| expect(c).to eq false }

      calls = []
      truthy = true
      SomePage.wait_for(5, 3) { calls << truthy; truthy }
      expect(calls.size).to eq 1
      expect(calls[0]).to eq true
    end
  end
end
