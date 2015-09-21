require_relative '../spec_helper.rb'

describe DockerCookery::BuildManager do
  describe '#create_build_queue' do
    it 'builds a queue for a package with no deps' do
      mgr = DockerCookery::BuildManager.new('foo', 'ubuntu-14.04', File.join('spec', 'fixtures', 'recipes'))
      expect(mgr.send(:create_build_queue, 'foo').length).to eq 1
    end

    it 'builds a queue for a package with simple deps' do
      mgr = DockerCookery::BuildManager.new('bar', 'ubuntu-14.04', File.join('spec', 'fixtures', 'recipes'))
      queue = mgr.send(:create_build_queue, 'bar')
      expect(queue.length).to eq 2
      expect(queue.first.recipe.name). to eq 'foo'
      expect(queue.last.recipe.name). to eq 'bar'
    end

    it 'builds a queue for a package with complex deps' do
      mgr = DockerCookery::BuildManager.new('complex-a', 'ubuntu-14.04', File.join('spec', 'fixtures', 'recipes'))
      queue = mgr.send(:create_build_queue, 'complex-a')
      expect(queue.length).to eq 5
      expect(queue.length == queue.uniq.length).to be_truthy
    end
  end
end
