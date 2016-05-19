require 'spec_helper'

module Sloth
  context 'when included' do
    class SomePage
      include PageObject
      include Sloth

      button :foo, id: 'foo'
      required :foo
    end

    let(:browser) { watir_browser }
    let(:page) { SomePage.new browser }

    it 'extends ClassMethods' do
      expect(SomePage.ancestors).to include Sloth::ClassMethods
    end

    it 'determines the platform' do
      expect(page.po_lib).to eq PageObject
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
        page.gather_underlying_elements
        expect(page._required_elements.size).to be 1
      end
    end

    describe '.required' do
      it 'responds to' do
        expect(SomePage).to respond_to :required
      end

      it 'defines a method .wait_for_required_elements' do
        expect(page).to respond_to :wait_for_required_elements
      end

      describe '.wait_for_required_elements' do
        before { page.wait_for_required_elements }
      end
    end
  end

  describe '.wait_for', type: :slow do
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
