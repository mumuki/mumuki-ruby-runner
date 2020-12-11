#!/bin/bash

TAG=$(grep -e 'mumuki/mumuki-rspec-worker:[0-9]*\.[0-9]*' ./lib/ruby_runner.rb -o | tail -n 1)

echo "Pulling $TAG..."
docker pull $TAG
