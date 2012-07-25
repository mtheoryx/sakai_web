# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sakai_web/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Poindexter"]
  gem.email         = ["davpoind@iupui.edu"]
  gem.description   = %q{Basic gem for interracting with Sakai Web Services}
  gem.summary       = %q{Basic gem for interracting with Sakai Web Services}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  # gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sakai_web"
  gem.require_paths = ["lib"]
  gem.version       = SakaiWeb::VERSION

  gem.add_development_dependency 'rake', "= 0.9.2"
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fuubar'
  gem.add_development_dependency 'fakeweb'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'autotest'
  gem.add_development_dependency 'autotest-fsevent'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'


  gem.add_runtime_dependency 'savon'
end
