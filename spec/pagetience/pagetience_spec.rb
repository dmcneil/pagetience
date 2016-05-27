require 'spec_helper'

class SomePage
  include PageObject
  include Pagetience

  element :foo, id: 'foo'
  required :foo
  waiting 3, 1
end

class AnotherPage < SomePage; end

class SomePageWithoutPlatform
  include Pagetience
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
    it 'should extend ClassMethods' do
      expect(SomePage.ancestors).to include Pagetience::ClassMethods
    end

    it 'should look at ancestors for a supported platform' do
      expect(page.element_platform).to be_a_kind_of Pagetience::ElementPlatforms::PageObjectGem
    end

    it 'should support optional params' do
      page = SomePage.new browser, true
      expect(page.loaded?).to eq true
    end

    it 'should look for a browser variable' do
      # pending
    end

    it 'should look for a known browser in any instance variables' do
      # pending
    end

    it 'should raise an exception if no platform found' do
      expect{SomePageWithoutPlatform.new(browser)}.to raise_error Pagetience::Exceptions::Platform
    end

    describe 'waiting defaults' do
      class WaitingDefaultsPage
        include PageObject
        include Pagetience

        element :foo, id: 'foo'
        required :foo
      end

      it 'should set the defaults' do
        expect(WaitingDefaultsPage.new(browser)._waiting_timeout).to eq 30
        expect(WaitingDefaultsPage.new(browser)._waiting_polling).to eq 1
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

        it 'should use the timeout specified by the waiting method' do
          expect(page._poller.timeout).to eq 3
        end

        it 'should use the polling specified by the waiting method' do
          expect(page._poller.polling).to eq 1
        end
      end
    end

    describe '.waiting' do
      it 'should be added to the class' do
        expect(SomePage).to respond_to :waiting
      end

      it 'should set the timeout' do
        expect(page._waiting_timeout).to eq 3
      end

      it 'should set the polling' do
        expect(page._waiting_polling).to eq 1
      end
    end

    describe '.transition_to' do
      it 'transitions to another page' do
        expect(page.transition_to(AnotherPage)).to be_an_instance_of AnotherPage
      end
    end
  end
end
