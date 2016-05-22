require 'spec_helper'

class KlazzWithPageObject
  include PageObject

  button :foo, id: 'foo'
end

describe Pagetience::Platforms::PageObjectGem do
  let(:browser) { mock_watir_browser }
  let(:element) { instance_double(Watir::Element) }
  let(:klazz) { KlazzWithPageObject.new browser }
  let(:platform) { Pagetience::Platforms::PageObjectGem.new klazz }

  it 'should not be considered a browser' do
    expect(platform.is_browser?).to eq false
  end

  it 'should have a browser' do
    expect(platform.browser).to eq klazz.browser
  end

  it 'should have a class instance that includes PageObject' do
    expect(platform.page_object_instance).to eq klazz
  end

  it 'should find an underlying element' do
    allow(browser).to receive(:button).with(id: 'foo').and_return(element)
    expect(platform.underlying_element_for(:foo)).to eq element
  end
end