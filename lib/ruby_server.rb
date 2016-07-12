require 'mumukit'

Mumukit.runner_name = 'ruby'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-rspec-worker'
  config.structured = true
end

require_relative './metadata_hook'
require_relative './test_hook'
require_relative './query_hook'