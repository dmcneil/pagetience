require 'pagetience/exceptions'
require 'pagetience/timer'
require 'pagetience/version'

module Pagetience
  SUPPORTED_ELEMENT_LIBS = [PageObject]

  attr_accessor :_waiting_timeout, :_waiting_polling

  attr_reader :browser
  attr_reader :loaded

  attr_reader :element_lib
  attr_reader :_poller, :_required_elements, :_underlying_elements

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(browser)
    @element_lib = self.class.ancestors.find { |m| SUPPORTED_ELEMENT_LIBS.include? m }
    raise StandardError, 'Could not determine what page object platform is being used.' unless @element_lib

    PageObject.instance_method(:initialize).bind(self).call(browser) if @element_lib == PageObject

    @browser = browser
    @loaded = false
    @_waiting_timeout = _waiting_timeout || 30
    @_waiting_polling = _waiting_polling || 1

    @_required_elements = _required_elements || []
    @_underlying_elements = []
    gather_underlying_elements
    wait_for_required_elements
  end

  def loaded?
    !!@loaded
  end

  def gather_underlying_elements
    if @element_lib == PageObject
      @_required_elements.each do |e|
        if respond_to? "#{e}_element"
          @_underlying_elements << self.send("#{e}_element").element
        end
      end
    end
  end

  def wait_for_required_elements
    @_poller = Pagetience::Timer.new(@_waiting_timeout, @_waiting_polling) do
      begin
        unless @_underlying_elements.any? { |e| !e.visible? }
          @loaded = true
        end
      rescue
        # TODO implement better strategy for certain platforms
      end
    end
    @_poller.run_until true

    unless loaded?
      raise Pagetience::Exceptions::Timeout, "Timed out after polling every #{@_poller.polling}s for #{@_poller.timeout}s waiting for the page to be loaded."
    end
  end

  module ClassMethods
    def required(*elements)
      elements.keep_if { |e| e.is_a? Symbol }
      define_method('_required_elements') do
        elements
      end
    end

    def waiting(timeout, polling=1)
      define_method('_waiting_timeout') do
        timeout
      end
      define_method('_waiting_polling') do
        polling
      end
    end
  end
end
