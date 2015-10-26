$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'docker-cookery/version'

Gem::Specification.new do |s|
  s.name = 'docker-cookery'
  s.version = DockerCookery::VERSION
  s.licenses = [ 'BSD' ]
  s.platform = Gem::Platform::RUBY
  s.summary = 'build fpm-coookery packages in isolation with docker'
  s.description = s.summary
  s.author = 'Mathieu Sauve-Frankel'
  s.email = 'msf@kisoku.net'
  s.homepage = 'https://github.com/kisoku/docker-cookery'
  s.require_path = 'lib'
  s.files = `git ls-files`.split($/)
  s.bindir = 'bin'
  s.executables = %w[ docker-cook ]

  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'fuubar', '~> 2.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-its', '~> 1.1'
  s.add_development_dependency 'safe_yaml', '~> 1.0'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_dependency 'bundler', '~> 1.6'
  s.add_dependency 'cabin', '~> 0.7'
  s.add_dependency 'clamp', '~> 0.6'
  s.add_dependency 'fpm-cookery', '~> 0.30'
  s.add_dependency 'mixlib-shellout', '~> 2.2'
  s.add_dependency 'mixlib-config', '~> 2.2'
end
