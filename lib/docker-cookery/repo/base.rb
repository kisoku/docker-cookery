require 'docker-cookery/mixin/shellout'

module DockerCookery
  class Repo
    class Base
      include Shellout
      attr_reader :name, :distribution, :prefix, :package_suffix

      def initialize(distribution, prefix='docker-cookery')
        @distribution = distribution
        @prefix = prefix
        @name = "#{prefix}-#{distribution}"
      end
    end
  end
end
