require 'sloth/exceptions'
require 'sloth/timer'
require 'sloth/version'

module Sloth
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def wait_for(timeout=30, polling=1, &block)
      if block_given?
        block.call
      end
    end
    alias_method :loaded?, :wait_for
  end
end
