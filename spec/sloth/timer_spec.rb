require 'sloth'

module Sloth
  describe Sloth::Timer do
    let(:timer) { Sloth::Timer.new }

    it 'has a default timeout of 30' do
      expect(timer).to have_attributes(timeout: 30)
    end

    it 'has a default polling time of 1' do
      expect(timer).to have_attributes(polling: 1)
    end

    it 'throws an argument error if timeout less than polling' do
      timer = Sloth::Timer.new(1, 5)
      expect{ timer.run }.to raise_error ArgumentError
    end

    it 'can start immediately optionally' do
      result = Sloth::Timer.new(5) { 'Hello' }.run
      expect(result).to eq 'Hello'
    end

    it 'will execute a block every N seconds' do
      calls = []
      timer = Sloth::Timer.new(18, 5) { calls << 'Hello' }
      timer.run
      expect(calls.size).to eq 3
    end
  end
end