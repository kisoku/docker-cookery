require_relative '../spec_helper.rb'

describe DockerCookery::Repo do
  describe '#new' do
    it 'returns a DockerCookery::Repo::Apt object when passed an ubuntu platform' do
      repo = DockerCookery::Repo.new('ubuntu-14.04')
      expect(repo).to be_a DockerCookery::Repo::Apt
    end

    it 'returns a DockerCookery::Repo::Yum object when passed an centos platform' do
      repo = DockerCookery::Repo.new('centos-6')
      expect(repo).to be_a DockerCookery::Repo::Yum
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

describe DockerCookery::Repo::Apt do
  let (:status) { double('Process::Status', :exitstatus => exitstatus) }
  let (:exitstatus) { 0 }
  let (:shell_out) { double('Mixlib::ShellOut', :status => status, :stdout => stdout, :stderr => stderr) }

  subject { DockerCookery::Repo::Apt.new('ubuntu-14.04') }

  describe '#create' do

    let (:stderr) { "" }
    let (:stdout) { "" }

    it 'should create itself using aptly' do
      allow(subject).to receive(:exist?).and_return(false)
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.create

      expect(subject).to have_received(:run!).with('aptly repo create docker-cookery-ubuntu-14.04')
    end
  end
end
