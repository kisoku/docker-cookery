require 'clamp'
require 'docker-cookery/config'
require 'docker-cookery/log'

module DockerCookery
  module CLI
    class BaseCommand < Clamp::Command

      option ['-c', '--config-file'], 'CONFIG_FILE', 'path to configuration file',
        attribute_name: :config_file, default: File.expand_path(File.join('~', '.docker-cookery', 'config.rb'))
      option ['-d', '--debug'], :flag, "enable debugging"

      def load_config
        local_config = File.join(Dir.pwd, '.docker-cookery', 'config.rb')
        if File.exist?(local_config)
          DockerCookery::Config.from_file(local_config)
        elsif File.exist?(config_file)
          DockerCookery::Config.from_file(config_file)
        end
        add_options_to_config
      end

      def init_logging
        Log.enable_debug(debug?)
        Log.output(FPM::Cookery::Log::Output::Console.new)
      end

      def execute
        load_config
        init_logging
        exec
      end

      private

      def add_options_to_config
        self.class.declared_options.each do |option|
          next if option.attribute_name == 'help'
          if option.type == :flag
            opt = option.attribute_name + '?'
          else
            opt = option.attribute_name
          end
          DockerCookery::Config.send(opt, self.send(opt))
        end
      end
    end
  end
end
