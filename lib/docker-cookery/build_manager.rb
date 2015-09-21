require 'fileutils'

require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'
require 'docker-cookery/recipe_loader'
require 'docker-cookery/repo'
require 'docker-cookery/package_builder'

module DockerCookery
  class BuildManager
    include Shellout

    DEFAULT_BUILD_TIMEOUT = 4800
    DEFAULT_CONFIG = {
      environment: nil,
      force: false,
      rm: true,
      prefix: 'docker-cookery',
      timeout: DEFAULT_BUILD_TIMEOUT,
      volumes: []
    }

    attr_reader :composer, :config, :image, :package, :recipe, :recipe_path, :repo, :stamp_dir

    def initialize(package, image, recipe_path, config=DEFAULT_CONFIG)
      @config = config
      @image = image
      @package = package
      @recipe_path = File.expand_path(recipe_path)
      @repo = Repo.new(image, config[:prefix])
      @stamp_dir = Dir.mktmpdir('docker-cook')
      config[:stamp_dir] = stamp_dir
      Log.puts "Tracking build state in stamp_dir: #{stamp_dir}"
    end

    def build
      begin
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

      pkg_builder = PackageBuilder.new(package_name, image, recipe_path, config)

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
