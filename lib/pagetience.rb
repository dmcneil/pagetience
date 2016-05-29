require 'pagetience/exceptions'
require 'pagetience/meditate'
require 'pagetience/version'

require 'pagetience/platforms/base'
require 'pagetience/platforms/page-object-gem'

require 'pagetience/platforms/element_platforms'

module Pagetience
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

  attr_accessor :_waiting_timeout, :_waiting_polling

  attr_reader :browser, :loaded

  attr_reader :element_platform
  attr_reader :_required_elements

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(browser, *args)
    @browser = browser

    current_page = self
    @browser.class.send(:define_method, :current_page) { current_page }

    determine_platform
    @element_platform.platform_initialize args

    @loaded = false
    @_waiting_timeout = _waiting_timeout || 30
    @_waiting_polling = _waiting_polling || 1

    @_required_elements = _required_elements || []
    wait_for_required_elements
  end

  def loaded?
    !!@loaded
  end

  def wait_for_required_elements(timeout=nil, polling=nil)
    opts = {
        timeout: timeout || @_waiting_timeout,
        polling: polling || @_waiting_polling,
        expecting: true,
        msg: "Timed out after polling every #{:polling}s for #{:timeout}s waiting for the page to be loaded."
    }
    wait_for(opts) do
      @loaded = true unless @_required_elements.any? { |e| !@element_platform.is_element_present? e }
    end
  end

  def wait_for_element(sym, timeout=nil, polling=nil)
    opts = {
        timeout: timeout || @_waiting_timeout,
        polling: polling || @_waiting_polling,
        expecting: true,
        msg: "Timed out after waiting for the element #{sym} to be present."
    }
    wait_for(opts) { @element_platform.is_element_present? sym }
  end

  def wait_for_transition_to(page, timeout=nil, polling=nil)
    page = page.new browser
    opts = {
        timeout: timeout || @_waiting_timeout,
        polling: polling || @_waiting_polling,
        expecting: true,
        msg: "Timed out after waiting for the page to transition to #{page}."
    }
    wait_for(opts) { page.loaded? }
    page
  end

  def wait_for(opts={}, &block)
    Pagetience::Meditate.for(opts) { block.call }
  end

  private

  def determine_platform
    @element_platform = Pagetience::ElementPlatforms::Base.find(self)

    raise Pagetience::Exceptions::Platform, 'Could not determine what element platform is being used.' unless @element_platform
  end
end
