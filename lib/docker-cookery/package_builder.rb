require 'fileutils'

require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'
require 'docker-cookery/recipe_loader'
require 'docker-cookery/repo'

module DockerCookery
  class PackageBuilder
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

    attr_reader :config, :image, :package, :recipe, :recipe_path, :repo

    def initialize(package, image, recipe_path, config=DEFAULT_CONFIG)
      @config = config
      @image = image
      @package = package
      @recipe_path = File.expand_path(recipe_path)
      @repo = Repo.new(image, config[:prefix])
      @recipe = RecipeLoader.new(recipe_path).load(package)
    end

    def package_dir
      File.expand_path(File.join(recipe_path, package))
    end

    def extra_volumes
      config.fetch(:volumes, [])
    end

    def wants_to_build?
      if config[:force]
        true
      else
        not repo.package_exist?(package, "#{recipe.version}-#{recipe.revision}")
      end
    end

    def build
      cmd = "docker run"
      cmd << " -i"
      cmd << " --rm=#{config[:rm]}"
      config[:environment].each do |env|
        cmd << " -e '#{env}'"
      end
      cmd << " -v #{File.join(File.dirname(__FILE__), 'helpers')}:/helpers"
      cmd << " -v #{package_dir}:/build"
      cmd << " -v #{repo.path}:/repo"
      extra_volumes.each do |volume|
        cmd << " -v #{volume}"
      end
      cmd << " fpm_docker/#{image} /helpers/cook #{image}"

      Dir.chdir(recipe_path) do
        if wants_to_build?
          Log.puts "Building #{package} from: #{package_dir}"
          Log.debug "Running build with command: #{cmd}"
          run!(cmd, { live_stream: STDOUT, timeout: 4800 })
          publish
        else
          Log.puts "Package #{package} already in repo #{repo.name}, skipping"
        end
      end
    end

    def stamp_name
      "#{package}-#{recipe.version}-#{recipe.revision}-#{image}"
    end

    def local_depends
      available_recipes = RecipeLoader.new(recipe_path).find
      depends = []
      depends.concat recipe.build_depends
      depends.concat recipe.depends
      depends.uniq!
      available_recipes & depends
    end

    def publish
      package_pattern = "#{package}*#{recipe.version}*#{repo.package_suffix}"

      Dir.chdir(package_dir) do
        packages = Dir.glob("packages/#{repo.distribution}/#{package_pattern}")
        if not packages.empty?
          packages.each do |pkg|
            repo.add_package(pkg)
            FileUtils.rm_f pkg
          end
        else
          Log.warn "no packages found after build with pattern: #{package_pattern}"
          exit 1
        end
        repo.publish
      end
    end
  end
end
