$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require_relative '../lib/sloth'

require 'page-object'
require 'watir-webdriver'

def watir_browser
  watir_browser = instance_double(Watir::Browser)
  allow(watir_browser).to receive(:is_a?).with(anything()).and_return(false)
  allow(watir_browser).to receive(:is_a?).with(Watir::Browser).and_return(true)
  watir_browser
end