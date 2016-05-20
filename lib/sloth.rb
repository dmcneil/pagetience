require 'sloth/exceptions'
require 'sloth/timer'
require 'sloth/version'

# require 'page-object'

module Sloth
  SUPPORTED_ELEMENT_LIBS = [PageObject]

  attr_reader :browser
  attr_reader :loaded

  attr_reader :element_lib
  attr_reader :_required_elements, :_underlying_elements

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(browser)
    @element_lib = self.class.ancestors.find { |m| SUPPORTED_ELEMENT_LIBS.include? m }
    raise StandardError, 'Could not determine what page object platform is being used.' unless @element_lib
    PageObject.instance_method(:initialize).bind(self).call(browser) if @element_lib == PageObject

    @browser = browser
    @loaded = false

    @_required_elements = _required_elements || []
    @_underlying_elements = []
    gather_underlying_elements
  end

  def loaded?
    @loaded
  end

  def gather_underlying_elements
    if @element_lib == PageObject
      _required_elements.each do |e|
        if respond_to? "#{e}_element"
          @_underlying_elements << self.send("#{e}_element").element
        end
      end
    end
  end

  def wait_for_required_elements
    timer = Sloth::Timer.new do
      return if loaded?
      if @_underlying_elements.any? { |e| !e.visible? }
        puts @_underlying_elements.find { |e| !e.visible? }
        @loaded = false
      end
    end
    @loaded = timer.run
  end

  module ClassMethods
    def required(*elements)
      elements.keep_if { |e| e.is_a? Symbol }
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
