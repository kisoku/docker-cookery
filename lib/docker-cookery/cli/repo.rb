require 'docker-cookery/cli/base'
require 'docker-cookery/log'
require 'docker-cookery/repo'

module DockerCookery
  module CLI
    class RepoCommand < Clamp::Command

      class BaseRepoCommand < BaseCommand
        parameter 'DISTRIBUTION', 'repository distribution name, corresponds to image name', attribute_name: :distribution
        parameter 'PREFIX', 'repository prefix', attribute_name: :prefix, default: 'docker-cookery'
      end

      class ShowCommand < BaseRepoCommand
        def exec
          r = Repo.new(distribution, prefix)
          Log.puts "#{r.name} #{r.path}"
        end
      end

      class CreateCommand < BaseRepoCommand
        def exec
          Repo.new(distribution, prefix).create
        end
      end

      class AddPackageCommand < BaseRepoCommand
        parameter 'PACKAGE', 'package to add', attribute_name: :package

        def exec
          Repo.new(distribution, prefix).add_package(package)
        end
      end

      class RmPackageCommand < BaseRepoCommand
        parameter 'PACKAGE', 'package to remove', attribute_name: :package

        def exec
          Repo.new(distribution, prefix).rm_package(package)
        end
      end


      class PublishCommand < BaseRepoCommand
        def exec
          Repo.new(distribution, prefix).publish
        end
      end

      class DropCommand < BaseRepoCommand
        def exec
          Repo.new(distribution, prefix).drop
        end
      end

      subcommand 'create', 'create package repository', CreateCommand
      subcommand 'drop', 'drop package repository', DropCommand
      subcommand 'publish', 'publish package repository', PublishCommand
      subcommand 'show', 'show repository info', ShowCommand
      subcommand 'add_package', 'add package to repo', AddPackageCommand
      subcommand 'rm_package', 'remove package from repo', RmPackageCommand
    end
  end
end
