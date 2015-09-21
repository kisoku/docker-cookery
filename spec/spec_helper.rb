require 'rspec'
require 'rspec/its'
require 'simplecov'

SimpleCov.start do
  add_filter '/docker/'
  add_filter '/pkg/'
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
end

require 'docker-cookery/build_manager'
require 'docker-cookery/repo'
require 'docker-cookery/recipe_loader'
require 'docker-cookery/package_builder'
