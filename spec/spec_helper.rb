$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require_relative '../lib/sloth'

require 'page-object'
require 'watir-webdriver'

def watir_browser
  watir_browser = instance_double(Watir::Browser)
end