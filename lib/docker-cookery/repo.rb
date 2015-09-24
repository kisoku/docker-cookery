require 'fileutils'
require 'json'

require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'

module DockerCookery
  class Repo

    def self.new(name, prefix='fpm-recipes')
      case name
      when /ubuntu|debian/
        Apt.new(name, prefix)
      when /centos|redhat/
        Yum.new(name, prefix)
      end
    end

    class Base
      include Shellout
      attr_reader :name, :distribution, :prefix, :package_suffix

      def initialize(distribution, prefix='docker-cookery')
        @distribution = distribution
        @prefix = prefix
        @name = "#{prefix}-#{distribution}"
      end
    end

    class Apt < Base
      ARCHITECTURES = %w(i386 amd64)

      def package_suffix
        'deb'
      end

      def path
        File.join(JSON.load(run!('aptly config show').stdout).fetch('rootDir'), "public",
                  "#{name}")
      end

      def exist?
        run!('aptly repo list -raw').stdout.split("\n").member?(name)
      end

      def published?
        repos = run!('aptly publish list -raw').stdout.split("\n")
        repos.member?("#{name} #{distribution}")
      end

      def package_exist?(package, version=nil)
        # XXX barf city
        if exist?
          begin
            info = run!("aptly repo search #{name} #{package}").stdout
            if version
              if info.match(version)
                true
              else
                false
              end
            else
              true
            end
          rescue Mixlib::ShellOut::ShellCommandFailed
            false
          end
        else
          false
        end
      end

      def create
        if not exist?
          Log.debug "creating apt repo for platform #{name}"
          run!("aptly repo create #{name}")
        end
        if not published?
          publish
        end
      end

      def drop
        if exist?
          run!("aptly repo drop #{name}")
        end
      end

      def publish
        if published?
          run!("aptly publish drop #{distribution} #{name}")
        end
        run!("aptly publish repo -distribution=#{distribution} -architectures=#{ARCHITECTURES.join(',')} #{name} #{name}")
      end

      def add_package(package)
        pkg_name = package_name_from_path(package)

        if package_exist? pkg_name
          rm_package(pkg_name)
        end
        run!("aptly repo add #{name} #{package}")
      end

      def rm_package(package)
        Log.debug "removing package #{package} from package cache"
        run!("aptly repo remove #{name} #{package}")
      end

      def package_name_from_path(path)
        _, _, file = path.split('/')
        file.match(/([^_]+)/)[0]
      end
    end

    class Yum < Base

      def package_suffix
        'rpm'
      end

      def path
        File.expand_path(File.join('~/.fpm-recipes', 'yum', "#{name}"))
      end

      def exist?
        Dir.exist?("#{path}/repodata") && File.exist?("#{path}/repodata/repomd.xml")
      end

      def published?
        # XXX this always republishes
        false
      end

      def package_exist?
        Dir.glob(File.join(path, '*')).member?(/#{package}-*.rpm/)
      end

      def create
        if not exist?
          puts "initializing apt repo for platform #{name}"
          FileUtils.mkdir_p(path)
          run!("createrepo #{path}")
        end
      end

      def publish
        run!("createrepo #{path}")
      end

      def add_package(package)
        FileUtils.cp(package, path)
      end

      def rm_package(package)
      end

      def drop
      end
    end
  end
end
