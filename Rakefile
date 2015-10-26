require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = [].tap do |a|
    a << '--default-path spec/unit'
    a << '-I spec/unit'
  end.join(' ')
end

task test: :spec


task test: :spec
task :default => :spec
