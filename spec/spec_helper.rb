require 'sakai_web'
require 'autotest'
require 'autotest/bundler'
require 'pry'
require 'Fuubar'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = 'documentation'
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.fail_fast = true
end
