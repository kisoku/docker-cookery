require 'clamp'
require 'fpm/cookery/log/output/console'
require 'docker-cookery/log'
require 'docker-cookery/cli/image'
require 'docker-cookery/cli/repo'
require 'docker-cookery/cli/package'

module DockerCookery
  module CLI
    class Command < Clamp::Command

      option ['-d', '--debug'], :flag, "enable debugging"

      def init_logging
        Log.enable_debug(debug?)
        Log.output(FPM::Cookery::Log::Output::Console.new)
      end

      def execute
        init_logging
        exec
      end

      subcommand 'image', 'build docker images', ImageCommand
      subcommand 'package', 'build fpm recipes using docker', PackageCommand
      subcommand 'repo', 'manage docker-cookery\'s package repositories', RepoCommand
    end
  end
end

# vi: ft=ruby
