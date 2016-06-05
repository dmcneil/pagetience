require 'pagetience/platforms/page-object-gem'

require 'pagetience/configuration'
require 'pagetience/meditate'
require 'pagetience/version'

module Pagetience
  class TimeoutError < StandardError; end
  class PlatformError < StandardError; end
  class ConfigurationError < StandardError; end

  class << self
    attr_writer :config

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
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

  # "Private" methods to avoid naming collision but remain helpful
  # They can be messed with though, if you ever see fit.
  attr_accessor :_waiting_timeout, :_waiting_polling, :_required_elements

  attr_reader :browser
  attr_reader :element_platform

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(*args)
    @browser = args[0]
    set_current_page

    @element_platform = Pagetience.config.platform.init self, args

    @loaded = false
    @_waiting_timeout = _waiting_timeout || Pagetience.config.timeout
    @_waiting_polling = _waiting_polling || Pagetience.config.polling
    @_required_elements = _required_elements || []
    @_present_elements = []
    @_missing_elements = []
    wait_for_required_elements
  end

  def loaded?
    !!@loaded
  end

  # Waits for all elements specified by .required to be present
  # @param [Fixnum] timeout Time to wait in seconds
  # @param [Fixnum] polling How often to poll
  def wait_for_required_elements(timeout=nil, polling=nil)
    msg = -> do
      %{Timed out after polling every #{@_waiting_polling}s for #{@_waiting_timeout}s waiting for the page to be loaded.
      Elements present: #{@_present_elements}
      Elements missing: #{@_missing_elements}}
    end

    opts = { timeout: timeout, polling: polling, msg: msg }
    wait_for(opts) do
      @_missing_elements = []
      @_required_elements.each do |e|
        if !@element_platform.is_element_present?(e) && !@_missing_elements.include?(e)
          @_missing_elements << e
          @_present_elements = @_required_elements - @_missing_elements
        end
      end
      @loaded = @_missing_elements.empty?
    end
  end

  # Wait for an element to be present
  # @param [Symbol] sym Name of the element
  # @param [Fixnum] timeout Time to wait in seconds
  # @param [Fixnum] polling How often to poll
  def wait_for_element(sym, timeout=nil, polling=nil)
    opts = {
        timeout: timeout,
        polling: polling,
        msg: "Timed out after waiting for the element #{sym} to be present."
    }
    wait_for(opts) { @element_platform.is_element_present? sym }
  end

  # Wait for a transition to another page
  # @param [Fixnum] timeout Time to wait in seconds
  # @param [Fixnum] polling How often to poll
  def wait_for_transition_to(page, timeout=nil, polling=nil)
    page = page.new browser
    opts = {
        timeout: timeout,
        polling: polling,
        msg: "Timed out after waiting for the page to transition to #{page}."
    }
    wait_for(opts) { page.loaded? }
    page
  end

  # Generic waiting method
  # @param [Hash] opts
  # Valid options:
  # :timeout = Time to wait in seconds
  # :polling = How often to poll
  # :expecting = The expected result for the block to return
  # :msg = The exception message if the timeout occurs
  def wait_for(opts={}, &block)
    opts = {
        timeout: @_waiting_timeout,
        polling: @_waiting_polling,
        expecting: true,
        msg: "Timed out after waiting for #{@_waiting_timeout}s, polling every #{@_waiting_polling}s."
    }.merge(opts) do |key, old, new|
      new.nil? ? old : new
    end
    Pagetience::Meditate.for(opts) { block.call }
  end

  private

  # Sets .current on the browser
  def set_current_page
    current_page = self
    @browser.class.send(:define_method, :current_page) { current_page }
  end
end
