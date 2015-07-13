#!/bin/bash
cd /app && bundle exec unicorn -c config/container/unicorn.rb
