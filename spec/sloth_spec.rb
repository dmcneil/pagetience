require 'sloth'

module Sloth
  context 'when included' do
    class SomePage
      include Sloth
    end

    it 'extends ClassMethods' do
      expect(SomePage.ancestors).to include Sloth::ClassMethods
    end

    it 'creates .wait_for' do
      expect(SomePage).to respond_to :wait_for
    end
  end

  describe '.wait_for' do
    class SomePage
      include Sloth
    end

    it 'will wait for a truthy block' do
      truthy = false
      expect{ SomePage.wait_for(5) { truthy }}.to raise_error Sloth::Exceptions::SlothTimeout
    end
  end
end
