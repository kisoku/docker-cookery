require 'docker-cookery/cli/base'
require 'docker-cookery/image_builder'
require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'

module DockerCookery
  module CLI
    class ImageCommand < Clamp::Command

      class ListCommand < BaseCommand
        def exec
          DockerCookery::Log.puts 'available images:'
          DockerCookery::Image.find_all.each do |i|
            Log.puts "\t#{i}"
          end
        end
      end

      class BuildCommand < BaseCommand
        option [ '-f', '--force'], :flag, 'force image build', default: false
        option [ '-r', '--rm'], :flag, 'remove intermediate images', default: true

        parameter 'IMAGES ...', 'images to build', attribute_name: :images

        def exec
          images.each do |image|
            image = DockerCookery::ImageBuilder.new(image, {force: force?, rm: rm?})
            image.build
          end
        end
      end

      subcommand 'list', 'list available images', ListCommand
      subcommand 'build', 'build docker images', BuildCommand
    end
  end
end
