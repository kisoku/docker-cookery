require_relative '../spec_helper.rb'

describe DockerCookery::Repo::CreateRepo do
  let (:status) { double('Process::Status', :exitstatus => exitstatus) }
  let (:exitstatus) { 0 }
  let (:shell_out) { double('Mixlib::ShellOut', :status => status, :stdout => stdout, :stderr => stderr) }

  subject { DockerCookery::Repo::CreateRepo.new('centos-6') }

  describe '#exist?' do
    it 'returns true when repository exists' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(File).to receive(:exist?).and_return(true)
      expect(subject.exist?).to be_truthy
    end

    it 'returns false when directory exists but repository does not exist' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(File).to receive(:exist?).and_return(false)
      expect(subject.exist?).to be_falsey
    end

    it 'returns false when directory does not exist' do
      allow(Dir).to receive(:exist?).and_return(false)
      expect(subject.exist?).to be_falsey
    end
  end

  describe '#published?' do
    it 'always republishes' do
      expect(subject.published?).to be_falsey
    end
  end

  describe '#package_exist?' do
    let (:package) { 'foo' }
    let (:version) { '1.0.0-1' }

    it 'returns false when the repo does not exist' do
      allow(subject).to receive(:exist?).and_return(false)
      expect(subject.package_exist?(package)).to be_falsey
    end

    it 'returns false when the package does not exist' do
      allow(Dir).to receive(:glob).and_return([])
      expect(subject.package_exist?(package)).to be_falsey
    end

    it 'returns true when the package exists with version' do
      allow(subject).to receive(:exist?).and_return(true)
      allow(Dir).to receive(:glob).and_return([ %Q{#{File.join(subject.path, "#{package}-#{version}.rpm")}}])
      expect(subject.package_exist?(package, version)).to be_truthy
    end

    it 'returns false when the package exists with different version' do
      allow(subject).to receive(:exist?).and_return(true)
      allow(Dir).to receive(:glob).and_return([ %Q{#{File.join(subject.path, "#{package}-0.9.0-1.rpm")}}])
      expect(subject.package_exist?(package, version)).to be_falsey
    end
  end

  describe '#create' do
    let (:stderr) { "" }
    let (:stdout) { "" }

    it 'should create itself using aptly' do
      allow(subject).to receive(:exist?).and_return(false)
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.create
      expect(subject).to have_received(:run!).with("createrepo #{subject.path}")
    end
  end

  describe '#drop' do
    it 'drops the repository if it exists' do
      allow(subject).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:rm_rf)
      subject.drop
      expect(FileUtils).to have_received(:rm_rf).with(subject.path)
    end
  end

  describe '#publish' do
    let (:stderr) { "" }
    let (:stdout) { "" }

    it 'publishes the repo' do
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.publish
      expect(subject).to have_received(:run!).with("createrepo #{subject.path}")
    end
  end

  describe '#add_package' do
    let (:package) { 'foo' }
    let (:package_path) { 'pkg/centos-6/foo-1.0.0-1.rpm' }

    it 'adds the package to the repo' do
      allow(subject).to receive(:package_exist?).and_return(false)
      allow(FileUtils).to receive(:cp)
      subject.add_package(package_path)
      expect(FileUtils).to have_received(:cp).with(package_path, subject.path)
    end

    it 'removes the package from the repo if it exists' do
      allow(subject).to receive(:package_exist?).and_return(true)
      allow(FileUtils).to receive(:cp)
      allow(subject).to receive(:rm_package)
      subject.add_package(package_path)
      expect(subject).to have_received(:rm_package).with(package)
    end
  end

  describe '#rm_package' do
    let (:package) { 'foo' }

    it 'removes the package from the repo if it exists' do
      allow(subject).to receive(:package_exist?).and_return(true)
      allow(FileUtils).to receive(:rm_f)
      subject.rm_package(package)
      expect(FileUtils).to have_received(:rm_f).with(File.join(subject.path, "#{package}-*.#{subject.package_suffix}"))
    end
  end
end
