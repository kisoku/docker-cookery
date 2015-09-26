require 'clamp'
require 'docker-cookery/log'

module DockerCookery
  module CLI
    class BaseCommand < Clamp::Command

      option ['-d', '--debug'], :flag, "enable debugging"

      def init_logging
        Log.enable_debug(debug?)
        Log.output(FPM::Cookery::Log::Output::Console.new)
      end

      def execute
        init_logging
        exec
      end
    end
  end
end
