require 'mumukit'

Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-rspec-worker'
  config.runner_name = 'rspec-server'
  config.structured = true
end

require_relative './test_compiler'
require_relative './test_runner'
require_relative './query_runner'
