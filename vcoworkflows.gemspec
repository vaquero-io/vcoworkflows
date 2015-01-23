# coding: utf-8
# rubocop:disable all
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vcoworkflows/version'

Gem::Specification.new do |spec|
  spec.name          = 'vcoworkflows'
  spec.version       = VcoWorkflows::VERSION
  spec.authors       = %w('Nic Cheneweth','Gregory Ruiz-ade')
  spec.email         = %w('Nic.Cheneweth@activenetwork.com','gregory.ruiz-ade@activenetwork.com')
  spec.summary       = 'vCO Workflows REST API Wrapper'
  spec.description   = 'Ruby implementation of vCenter Orchestrator REST API'
  spec.homepage      = ''
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '>= 0.27.0'
  spec.add_development_dependency 'aruba', '>= 0.6'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'coveralls', '= 0.7.1'
  spec.add_development_dependency 'guard', '>= 2.10.0'
  spec.add_development_dependency 'guard-rubocop', '>= 1.1.0'
  # growl functionality in Guardfile depends on growl-notify
  spec.add_development_dependency 'growl', '>= 1.0'
  spec.add_development_dependency 'yard', '>= 0.8'

  # spec.add_dependency 'thor'
  spec.add_dependency 'thor', '>= 0.18.0'
  spec.add_dependency 'rest-client'

end
# rubocop:enable all
