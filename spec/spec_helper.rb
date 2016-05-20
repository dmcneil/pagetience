$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'pry'

require 'watir-webdriver'
require 'selenium-webdriver'
require 'page-object'

require 'pagetience'

# Borrowed from page-object gem specs
def mock_watir_browser
  watir_browser = double('watir')
  allow(watir_browser).to receive(:is_a?).with(anything()).and_return(false)
  allow(watir_browser).to receive(:is_a?).with(Watir::Browser).and_return(true)
  watir_browser
end

RSpec.configure do |c|
  c.filter_run_excluding type: :slow
end
