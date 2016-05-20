require 'spec_helper'

class SomePage
  include PageObject
  include Sloth

  element :foo, id: 'foo'
  required :foo
end

describe Sloth do
  let(:browser) { mock_watir_browser }
  let(:page) { SomePage.new(browser) }
  let(:element) { instance_double(Watir::Element) }

  before {
    allow(browser).to receive(:element).with({id: 'foo'}).and_return(element)
  }

  context 'when included' do
    it 'extends ClassMethods' do
      expect(SomePage.ancestors).to include Sloth::ClassMethods
    end

    it 'determines the platform' do
      expect(page.element_lib).to eq PageObject
    end

    describe '.wait_for' do
      it 'responds to' do
        expect(SomePage).to respond_to :wait_for
      end
    end

    describe '.gather_underlying_elements' do
      it 'respond_to' do
        expect(page).to respond_to :gather_underlying_elements
      end

      it 'returns only objects for the specified platform' do
        expect(page._underlying_elements.size).to be 1
      end
    end

    describe '.required' do
      it 'should add the method to the page' do
        expect(SomePage).to respond_to :required
      end

      it 'should define .wait_for_required_elements' do
        expect(page).to respond_to :wait_for_required_elements
      end

      describe '.wait_for_required_elements' do
        it 'should be loaded when all the required elements are visible' do
          allow(element).to receive(:visible?).and_return true
          expect(page.loaded?).to be false
          page.wait_for_required_elements
          expect(page.loaded?).to be true
        end

        it 'should timeout if an element is never visible' do
          allow(element).to receive(:visible?).and_return false
          expect { page.wait_for_required_elements }.to raise_error Sloth::Exceptions::Timeout
        end
      end
    end
  end

  describe '.wait_for', type: :slow do
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
