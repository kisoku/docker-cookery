require 'docker-cookery/repo/base'

module DockerCookery
  class Repo
    class CreateRepo < Base

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

      def package_exist?(package, version=nil)
        glob_path = File.join(path, "*.#{package_suffix}")
        package_path = File.join(path, "#{package}-#{version}.#{package_suffix}")
        if exist?
          Dir.glob(glob_path).member?(package_path)
        else
          false
        end
      end

      def create
        if not exist?
          Log.debug "creating yum repo for platform #{name}"
          FileUtils.mkdir_p(path)
        end
        if not published?
          publish
        end
      end

      def drop
        if exist?
          FileUtils.rm_rf(path)
        end
      end

      def publish
        run!("createrepo #{path}")
      end

      def add_package(package_path)
        pkg_name = package_name_from_path(package_path)

        if package_exist?(pkg_name)
          rm_package(pkg_name)
        end
        FileUtils.cp(package_path, path)
      end

      def rm_package(package)
        if package_exist?(package)
          FileUtils.rm_f File.join(path, "#{package}-*.#{package_suffix}")
        end
      end

      private

      def package_name_from_path(path)
        _, _, file = path.split('/')
        file.match(/([^-]+)/)[0]
      end
    end
  end
end
