require 'rubygems/tasks'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = [].tap do |a|
    a << '--color'
    a << '--format Fuubar'
    a << '--backtrace '
    a << "--default-path test"
    a << '-I test/spec'
  end.join(' ')
end

task test: :spec


Gem::Tasks.new
