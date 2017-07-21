ruby '2.1.2'
source 'https://rubygems.org'

gem 'sinatra'
gem 'tilt', '~> 1.4.1'
gem 'tilt-jbuilder'
gem 'jbuilder', '2.0.7'
gem 'rest-client'
gem 'require_all'
gem 'puma', '~> 3.0'
gem 'mina', '~> 0.3.6'
gem 'mina-puma', require: false

group :development do
  gem 'shotgun'
  gem 'pry'
  gem 'awesome_print'
end

group :test do
  gem 'vcr'
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'webmock'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'rack-test'
end

group :production do
  gem 'foreman', '0.66.0'
  gem 'unicorn'
end

gem 'endpoint_base', github: 'spree/endpoint_base'
