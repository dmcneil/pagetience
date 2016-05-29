require 'spec_helper'

class KlazzWithPageObject
  include PageObject

  button :foo, id: 'foo'
end

describe Pagetience::ElementPlatforms::PageObjectGem do
  let(:browser) { mock_watir_browser }
  let(:element) { instance_double(Watir::Element) }
  let(:klazz) { KlazzWithPageObject.new browser }
  let(:platform) { Pagetience::ElementPlatforms::PageObjectGem.new klazz }

  it 'should have a browser' do
    expect(platform.browser).to eq klazz.browser
  end

  it 'should optionally take the visit param' do
    class KlazzPage
      include PageObject
      include Pagetience

      button :foo, id: 'foo'
    end

    klazz = KlazzPage.new browser, true
    expect(klazz.visit).to eq true
  end

  it 'should have a class instance that includes PageObject' do
    expect(platform.page_object_instance).to eq klazz
  end

  it 'should find an underlying element' do
    allow(browser).to receive(:button).with(id: 'foo').and_return element
    expect(platform.underlying_element_for(:foo)).to eq element
  end

  it 'checks if an element is present' do
    allow(element).to receive(:visible?).and_return false
    allow(element).to receive(:present?).and_return false
    allow(browser).to receive(:button).with(id: 'foo').and_return element
    begin
      platform.is_element_present? :foo
    rescue
      # ignored
    end
    allow(element).to receive(:visible?).and_return true
    allow(element).to receive(:present?).and_return true
    expect(platform.is_element_present?(:foo)).to eq true
  end
end