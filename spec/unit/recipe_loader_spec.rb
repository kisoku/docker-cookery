require_relative '../spec_helper'

require 'fpm/cookery/recipe'

describe DockerCookery::RecipeLoader do
  describe '#load' do
    it 'load a recipe from disk' do
      loader = DockerCookery::RecipeLoader.new(File.join('spec', 'fixtures', 'recipes'))
      recipe = loader.load('foo')
      expect(recipe.ancestors).to include FPM::Cookery::Recipe
    end
  end

  describe '#find' do
    it 'finds all recipes in a given recipe_path' do
      loader = DockerCookery::RecipeLoader.new(File.expand_path(File.join('spec', 'fixtures', 'recipes')))
      expect(loader.find).to include('foo', 'bar')
      expect(loader.find).not_to include('.empty')
    end
  end
end
