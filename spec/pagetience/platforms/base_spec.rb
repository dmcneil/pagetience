require 'spec_helper'

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
end