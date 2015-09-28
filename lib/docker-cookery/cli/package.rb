require 'docker-cookery/cli/base'
require 'docker-cookery/build_manager'

module DockerCookery
  module CLI
    class PackageCommand < Clamp::Command

      class BuildCommand < BaseCommand
        option ['-e', '--env'], 'ENVIRONMENT', 'environment varable to pass to docker',
          multivalued: true, attribute_name: :environment
        option ['-f', '--force'], :flag, 'force build', default: false
        option ['-r', '--rm'], :flag, 'remove container after build', default: true
        option ['-R', '--recipe_path'], 'RECIPE_PATH', 'path to recipe directory', default: Dir.pwd
        option ['-p', '--prefix'], 'PREFIX', 'docker-cookery repo prefix', default: 'docker-cookery'
        option ['-v', '--volume'], 'VOLUME', 'additional volumes to mount in the container', multivalued: true,
          attribute_name: :volumes

        parameter 'RECIPE', 'recipe to build', attribute_name: :recipe
        parameter 'IMAGE', 'image to build on', attribute_name: :image

        def exec
          recipe_dir = File.expand_path(recipe)
          build_mgr = DockerCookery::BuildManager.new(recipe, image, recipe_path)
          build_mgr.build
        end
      end

      subcommand 'build', 'build specified package using fpm-docker image', BuildCommand
    end
  end
end
