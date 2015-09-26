require_relative '../spec_helper.rb'

describe DockerCookery::Repo do
  describe '#new' do
    it 'returns a DockerCookery::Repo::Apt object when passed an ubuntu platform' do
      repo = DockerCookery::Repo.new('ubuntu-14.04')
      expect(repo).to be_a DockerCookery::Repo::Aptly
    end

    it 'returns a DockerCookery::Repo::Yum object when passed an centos platform' do
      repo = DockerCookery::Repo.new('centos-6')
      expect(repo).to be_a DockerCookery::Repo::CreateRepo
    end

    it 'sets a default prefix' do
      repo = DockerCookery::Repo.new('ubuntu-14.04')
      expect(repo.prefix).to eq 'fpm-recipes'
    end

    it 'sets a custom prefix' do
      repo = DockerCookery::Repo.new('ubuntu-14.04', 'foo')
      expect(repo.prefix).to eq 'foo'
    end
  end
end
