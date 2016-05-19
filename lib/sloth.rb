require 'sloth/exceptions'
require 'sloth/timer'
require 'sloth/version'

require 'page-object'

module Sloth
  SUPPORTED_PO_LIBS = [PageObject]

  attr_reader :po_lib, :_underlying_elements

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(browser)
    @po_lib = self.class.ancestors.find { |a| SUPPORTED_PO_LIBS.include? a }
    raise StandardError, 'Could not determine what page object platform is being used.' unless @po_lib

    @_underlying_elements = []
    gather_underlying_elements
  end

  def gather_underlying_elements
    if @po_lib == PageObject
      _required_elements.each do |e|
        if respond_to? "#{e}_element"
          @_underlying_elements << method("#{e}_element".to_sym).call
        end
      end
    end
  end

  def wait_for_required_elements
    puts @_underlying_elements
  end

  module ClassMethods
    def required(*elements)
      define_method('_required_elements') do
        elements
      end
    end

    def wait_for(timeout=30, polling=1, &block)
      timer = Sloth::Timer.new(timeout, polling)
      timer.block = block
      result = timer.run
      if result == nil || result == false
        raise Sloth::Exceptions::Timeout
      end
    end
  end
end
