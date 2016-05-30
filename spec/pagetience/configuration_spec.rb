require 'spec_helper'

describe Pagetience::Configuration do
  describe '.configure' do
    it 'only lets you set certain properties' do
      expect {
        Pagetience.configure do |c|
          c.bad_property = 30
        end
      }.to raise_error Pagetience::ConfigurationError
    end
  end
end