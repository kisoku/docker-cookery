require 'fileutils'

require 'docker-cookery/config'
require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'
require 'docker-cookery/recipe_loader'
require 'docker-cookery/repo'
require 'docker-cookery/package_builder'

module DockerCookery
  class BuildManager
    include Shellout

    attr_reader :image, :package, :recipe_path

    def initialize(package, image, recipe_path)
      @image = image
      @package = package
      @recipe_path = File.expand_path(recipe_path)
    end

    def config
      DockerCookery::Config
    end

    def repo
      @repo ||= Repo.new(image, config[:prefix])
    end

    def stamp_dir
      @stamp_dir ||= Dir.mktmpdir('docker-cook')
    end

    def build
      begin
        Log.puts "Tracking build state in stamp_dir: #{stamp_dir}"
        repo.create
        queue = create_build_queue(package)
        queue.each do |pkg_builder|
          pkg_builder.build
        end
      ensure
        Log.puts "Cleaning up stamp_dir: #{stamp_dir}"
        FileUtils.rm_rf(stamp_dir)
      end
    end

    private

    def create_build_queue(package_name)
      queue = []

      pkg_builder = PackageBuilder.new(package_name, image, recipe_path)

      pkg_builder.local_depends.each do |dep|
        queue.concat(create_build_queue(dep))
      end

      # place top-level package at end of queue
      queue << pkg_builder
      queue.uniq {|pkg| pkg.recipe.name }
    end

    def build_package(pkg_builder)
      # don't build package if this builder has already built it once
      stamp = File.join(stamp_dir, pkg_builder.stamp_name)
      if not File.exist?(stamp)
        pkg_builder.build
      end

      # update the build stamp for this package
      FileUtils.touch(stamp)
    end
  end
end
