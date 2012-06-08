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
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sakai_web"
  gem.require_paths = ["lib"]
  gem.version       = SakaiWeb::VERSION
end
