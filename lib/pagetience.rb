require 'pagetience/exceptions'
require 'pagetience/timer'
require 'pagetience/version'

require 'pagetience/platforms/base'
require 'pagetience/platforms/page-object-gem'

require 'pagetience/platforms/platforms'

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

  SUPPORTED_PLATFORMS = {
      ancestors: [
          {name: 'page-object', module: PageObject, platform: Pagetience::Platforms::PageObjectGem}
      ]
  }

  attr_accessor :_waiting_timeout, :_waiting_polling

  attr_reader :browser
  attr_reader :loaded

  attr_reader :element_platform
  attr_reader :_poller, :_required_elements, :_underlying_elements

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(browser)
    @browser = browser

    determine_platform
    @element_platform.platform_initialize

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
    @_required_elements.each do |e|
      @_underlying_elements << @element_platform.underlying_element_for(e)
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

  private

  def determine_platform
    # Search the ancestors
    self.class.ancestors.find { |a| SUPPORTED_PLATFORMS[:ancestors].include? a }
    SUPPORTED_PLATFORMS[:ancestors].each do |p|
      if self.class.ancestors.include? p[:module]
        @element_platform = p[:platform].new self
      end
    end

    raise StandardError, 'Could not determine what page object platform is being used.' unless @element_platform
  end

  def platform_in_ancestors?
    self.class.ancestors.find {}
  end
end
