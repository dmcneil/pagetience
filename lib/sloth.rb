require 'sloth/exceptions'
require 'sloth/timer'
require 'sloth/version'

require 'page-object'

module Sloth
  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(browser)
    if self.class.ancestors.any? { |a| a == PageObject }

    end
  end

  def something
    puts 'sometjhin'
  end

  module ClassMethods
    def required(*elements)
      define_method('wait_for_required_elements') do

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
    alias_method :loaded?, :wait_for
  end
end
