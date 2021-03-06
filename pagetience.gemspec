# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pagetience/version'

Gem::Specification.new do |spec|
  spec.name          = 'pagetience'
  spec.version       = Pagetience::VERSION
  spec.authors       = ['Derek McNeil']
  spec.email         = ['derek.mcneil90@gmail.com']

  spec.summary       = %q{A simple gem for making page object waiting easy.}
  spec.homepage      = 'http://www.github.com/dmcneil/pagetience'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard', '~> 2.13.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.6.5'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'

  spec.add_dependency 'page-object' , '~> 1.1.1'
  spec.add_dependency 'watir-webdriver', '~> 0.9.0'
end
