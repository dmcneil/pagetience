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
    allow(element).to receive(:present?).and_return(true)
  }

  context 'when included' do
    it 'should extend ClassMethods' do
      expect(SomePage.ancestors).to include Pagetience::ClassMethods
    end

    it 'should support optional params' do
      page = SomePage.new browser, true
      expect(page.loaded?).to eq true
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
          allow(element).to receive(:present?).and_return false
          begin
            page.wait_for_required_elements
          rescue
            # ignored
          end
          allow(element).to receive(:visible?).and_return true
          allow(element).to receive(:present?).and_return true
          page.wait_for_required_elements
          expect(page.loaded?).to be true
        end

        it 'times out and lists which elements were never found' do
          allow(element).to receive(:visible?).and_return false
          allow(element).to receive(:present?).and_return false

          expected_msg = /Timed out after polling every \d+s for \d+s waiting for the page to be loaded.\s*Elements present: \[\]\s*Elements missing: \[:\w+\]/

          expect{ page.wait_for_required_elements }.to raise_error Pagetience::TimeoutError, expected_msg
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

    describe '.wait_for_transition_to' do
      it 'transitions to another page' do
        expect(page.wait_for_transition_to(AnotherPage)).to be_an_instance_of AnotherPage
      end
    end

    describe 'browser helpers' do
      it 'keeps track of the current page' do
        expected_page = page.wait_for_transition_to AnotherPage
        expect(browser.current_page).to eq expected_page
      end
    end

    describe '.wait_for_element' do
      it 'waits for an element to be present' do
        allow(element).to receive(:visible?).and_return false
        allow(element).to receive(:present?).and_return false
        begin
          page.wait_for_element :foo
        rescue
          # ignored
        end
        allow(element).to receive(:visible?).and_return true
        allow(element).to receive(:present?).and_return true
        page.wait_for_element :foo
      end
    end
  end
end
