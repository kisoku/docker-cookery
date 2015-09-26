require_relative '../spec_helper'

require 'fpm/cookery/recipe'

describe DockerCookery::RecipeLoader do

  subject { DockerCookery::RecipeLoader.new(File.join('spec', 'fixtures', 'recipes')) }

  describe '#load' do
    it 'loads a standard recipe from disk' do
      recipe = subject.load('foo')
      expect(recipe.ancestors).to include FPM::Cookery::Recipe
    end

    it 'loads a nonstandard recipe from disk' do
      recipe = subject.load('python-module')
      expect(recipe.ancestors).to include FPM::Cookery::PythonRecipe
    end

    it 'does not load classes that are not derived from FPM::Cookery::BaseRecipe' do
      expect { subject.load('bogus') }.to raise_exception(RuntimeError, 'No valid recipes found while attempting to load recipe: bogus')
    end

    it 'does not load recipe files with multiple recipes' do
      expect { subject.load('doubletrouble') }.to raise_exception(RuntimeError, 'More than one recipe defined in recipe: doubletrouble')
    end
  end

  describe '#find' do
    it 'finds all recipes in a given recipe_path' do
      expect(subject.find).to include('foo', 'bar')
      expect(subject.find).not_to include('.empty')
    end
  end

  describe '#exist?' do
    it 'returns true for existing recipes' do
      expect(subject.exist?('foo')).to be_truthy
    end

    it 'returns false for non-existing recipes' do
      expect(subject.exist?('nonexistent')). to be_falsey
    end
  end

  describe '#has_gemfile?' do
    it 'returns true when loading a recipe that contains a Gemfile' do
      expect(subject.has_gemfile?('gemfile')).to be_truthy
    end

    it 'returns false when loading a recipe that does not contain a Gemfile' do
      expect(subject.has_gemfile?('foo')).to be_falsey
    end
  end

  describe '#install_bundle' do
    let (:status) { double('Process::Status', :exitstatus => exitstatus) }
    let (:exitstatus) { 0 }
    let (:shell_out) { double('Mixlib::ShellOut', :status => status, :stdout => stdout, :stderr => stderr) }
    let (:stderr) { '' }
    let (:stdout) { '' }

    it 'runs bundle install if a Gemfile is present' do
      allow(subject).to receive(:has_gemfile?).and_return(true)
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.install_bundle('foo')
      expect(subject).to have_received(:run!).with('bundle install')
    end
  end
end
