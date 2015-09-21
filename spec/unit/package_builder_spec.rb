require_relative '../spec_helper.rb'

describe DockerCookery::PackageBuilder do
  describe '#local_depends' do
    subject { DockerCookery::PackageBuilder.new('bar', 'ubuntu-14.04', File.expand_path(File.join('spec', 'fixtures', 'recipes'))).local_depends }
    it { is_expected.to contain_exactly('foo') }
  end
end
