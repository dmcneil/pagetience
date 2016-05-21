require 'spec_helper'

class SomePage
  include PageObject
  include Pagetience

  element :foo, id: 'foo'
  required :foo
end

describe Pagetience do
  let(:browser) { mock_watir_browser }
  let(:page) { SomePage.new(browser) }
  let(:element) { instance_double(Watir::Element) }

  before {
    allow(browser).to receive(:element).with({id: 'foo'}).and_return(element)
    allow(element).to receive(:visible?).and_return(true)
  }

  context 'when included' do
    it 'extends ClassMethods' do
      expect(SomePage.ancestors).to include Pagetience::ClassMethods
    end

    it 'determines the platform' do
      expect(page.element_lib).to eq PageObject
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
          allow(element).to receive(:visible?).and_return false
          begin
            page.wait_for_required_elements
          rescue
            # ignored
          end
          allow(element).to receive(:visible?).and_return true
          page.wait_for_required_elements
          expect(page.loaded?).to be true
        end

        it 'should timeout if an element is never visible' do
          allow(element).to receive(:visible?).and_return false
          expect { page.wait_for_required_elements }.to raise_error Pagetience::Exceptions::Timeout
        end
      end
    end
  end
end
