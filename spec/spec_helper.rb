require 'sakai_web'
require 'vcr'

VCR.configure do |c|
	c.cassette_library_dir = 'spec/support/cassettes'
	c.hook_into :fakeweb
end

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
	config.extend VCR::RSpec::Macros
end
