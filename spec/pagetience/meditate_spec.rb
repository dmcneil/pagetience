require 'spec_helper'

describe Pagetience::Meditate do
  let(:timer) { Pagetience::Meditate.new }

  it 'has a default timeout of 30' do
    expect(timer).to have_attributes(timeout: 30)
  end

  it 'has a default polling time of 1' do
    expect(timer).to have_attributes(polling: 1)
  end

  it 'throws an argument error if timeout less than polling' do
    timer = Pagetience::Meditate.new(1, 5)
    expect{ timer.until_enlightened }.to raise_error ArgumentError
  end

  it 'will execute a block every N seconds', type: :slow do
    calls = []
    timer = Pagetience::Meditate.new(18, 5) { calls << 'Hello' }
    timer.until_enlightened
    expect(calls.size).to eq 3
  end
end