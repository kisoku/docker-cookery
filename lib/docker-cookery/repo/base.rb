require 'docker-cookery/config'
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

      def config
        DockerCookery::Config
      end

      def package_suffix
        case distribution
        when /^(debian|ubuntu)-*/
          'deb'
        when /^(redhat|centos|fedora)-*/
          'rpm'
        else
          '*'
        end
      end

      def path
        raise NotImplementedError
      end

      def exist?
        raise NotImplementedError
      end

      def published?
        raise NotImplementedError
      end

      def package_exist?(package, version=nil)
        raise NotImplementedError
      end

      def create
        raise NotImplementedError
      end

      def drop
        raise NotImplementedError
      end

      def publish
        raise NotImplementedError
      end

      def add_package(package_path)
        raise NotImplementedError
      end

      def rm_package(package)
        raise NotImplementedError
      end
    end
  end
end
