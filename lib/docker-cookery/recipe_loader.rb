require 'fpm/cookery/recipe'

require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'

module DockerCookery
  class RecipeLoader
    include DockerCookery::Shellout

    attr_accessor :recipe_path

    def initialize(recipe_path)
      @recipe_path = recipe_path
    end

    def find
      r = []

      Log.debug "Loading recipes from #{recipe_path}"
      Dir.entries(recipe_path).each do |f|
        next if File.file? f
        next if f == '.' or f == '..'
        if File.file?(File.join(recipe_path, f, 'recipe.rb'))
          r << f
        end
      end

      Log.debug "Found #{r.length} recipes"
      r.sort
    end

    def exist?(recipe)
      find.member?(recipe)
    end

    def has_gemfile?(recipe)
      File.exist?(File.join(recipe_path, recipe, 'Gemfile'))
    end

    def install_bundle(recipe)
      if has_gemfile?(recipe)
        Dir.chdir(File.join(recipe_path, recipe)) do
          Log.debug('Installing gem dependencies using bundler')
          run!('bundle install')
        end
      end
    end

    def load(recipe)
      install_bundle(recipe)
      Log.debug "Loading recipe #{recipe} from #{recipe_path}"
      m = Module.new
      m.class_eval(IO.read(File.join(recipe_path, recipe, 'recipe.rb')))

      recipes = m.constants.collect do |c|
        const = m.const_get(c)
        if const.is_a? Class and const < FPM::Cookery::BaseRecipe
          const
        else
          # this will cause a nil to be added to the collection, which must be
          # removed before proceeding
          next
        end
      end

      # strip all nil values from our collection of constants
      recipes.reject! {|x| x.nil? }

      if recipes.length > 1
        raise RuntimeError, "More than one recipe defined in recipe: #{recipe}"
      elsif recipes.empty?
        raise RuntimeError, "No valid recipes found while attempting to load recipe: #{recipe}"
      else
        recipes.first
      end
    end
  end
end
