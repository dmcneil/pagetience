require 'spec_helper'

class SomePageWithInclude
  include PageObject
end

describe Pagetience::Platforms::Base do
  let (:platform) { Pagetience::Platforms::Base.new }

  it 'should respond to underlying_element_for' do
    expect(platform).to respond_to(:underlying_element_for).with(1).argument
  end

  it 'should respond to platform_initialize' do
    expect(platform).to respond_to(:platform_initialize)
  end

  it 'should respond to is_browser?' do
    expect(platform).to respond_to(:is_browser?)
  end

  it 'should respond to browser' do
    expect(platform).to respond_to(:browser)
  end

  it 'should respond to self.present?(klazz)' do
    expect(Pagetience::Platforms::Base).to respond_to(:find).with(1).argument
  end

  describe 'self.present(?klazz)' do
    let(:browser) { mock_watir_browser }
    let(:page) { SomePageWithInclude.new browser }

    it 'should search the ancestors' do
      expect(Pagetience::Platforms::Base.find(page)).to be_a_kind_of Pagetience::Platforms::PageObjectGem
    end
  end
end