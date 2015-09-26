require_relative '../spec_helper.rb'

describe DockerCookery::Repo::Aptly do
  let (:status) { double('Process::Status', :exitstatus => exitstatus) }
  let (:exitstatus) { 0 }
  let (:shell_out) { double('Mixlib::ShellOut', :status => status, :stdout => stdout, :stderr => stderr) }
  let (:package) { 'foo' }
  let (:version) { '1.0.0-1' }
  let (:package_path) { "pkg/ubuntu-14.04/#{package}_#{version}_amd64.#{subject.package_suffix}" }

  subject { DockerCookery::Repo::Aptly.new('ubuntu-14.04') }

  describe '#path' do
    let (:stderr) { '' }
    let (:stdout) { '{ "rootDir": "/aptly" }' }

    it 'should return the path to the aptly repository' do
      allow(subject).to receive(:run!).and_return(shell_out)
      expect(subject.path).to eq "/aptly/public/#{subject.name}"
    end
  end

  describe '#exist?' do
    context 'repository exists' do
      let (:stderr) { '' }
      let (:stdout) { "docker-cookery-ubuntu-14.04\n" }

      it 'should return true when the repository exists' do
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.exist?).to be_truthy
      end
    end

    context 'repository does not exist' do
      let (:stderr) { '' }
      let (:stdout) { "docker-cookery-ubuntu-12.04\n" }

      it 'should return false when the repository does not exist' do
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.exist?).to be_falsey
      end
    end
  end

  describe '#published?' do
    context 'repository is published' do
      let (:stderr) { '' }
      let (:stdout) { "docker-cookery-ubuntu-14.04 ubuntu-14.04\n" }

      it 'should return true when repository is published' do
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.published?).to be_truthy
      end
    end

    context 'repository is not published' do
      let (:stderr) { '' }
      let (:stdout) { '' }

      it 'should return true when repository is published' do
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.published?).to be_falsey
      end
    end
  end

  describe '#package_exist?' do
    context 'repo does not exist' do
      it 'should return false when the repo does not exist' do
        allow(subject).to receive(:exist?).and_return(false)
        expect(subject.package_exist?(package, version)).to be_falsey
      end
    end

    context 'package does not exist' do
      let (:status) { 1 }
      let (:stderr) { '' }
      let (:stdout) { 'ERROR: no results' }

      it 'should return false when the package does not exists' do
        allow(subject).to receive(:exist?).and_return(true)
        allow(subject).to receive(:run!).and_raise(Mixlib::ShellOut::ShellCommandFailed)
        expect(subject.package_exist?(package, version)).to be_falsey
      end
    end

    context 'package exists with version specified' do
      let (:stderr) { '' }
      let (:stdout) { "#{package}_#{version}_amd64\n" }

      it 'should return true when the package exists with version' do
        allow(subject).to receive(:exist?).and_return(true)
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.package_exist?(package, version)).to be_truthy
      end
    end

    context 'package exists and version is not specified' do
      let (:stderr) { '' }
      let (:stdout) { "#{package}_#{version}_amd64\n" }

      it 'should return true when the package exists with no version' do
        allow(subject).to receive(:exist?).and_return(true)
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.package_exist?(package)).to be_truthy
      end
    end

    context 'package exists with different version' do
      let (:stderr) { '' }
      let (:stdout) { "foo_0.9.0-1_amd64\n" }

      it 'should return true when the package exists with version' do
        allow(subject).to receive(:exist?).and_return(true)
        allow(subject).to receive(:run!).and_return(shell_out)
        expect(subject.package_exist?('foo', '1.0.0-1')).to be_falsey
      end
    end
  end

  describe '#create' do
    let (:stderr) { '' }
    let (:stdout) { '' }

    it 'should create itself using aptly' do
      allow(subject).to receive(:exist?).and_return(false)
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.create
      expect(subject).to have_received(:run!).with('aptly repo create docker-cookery-ubuntu-14.04')
    end
  end

  describe '#drop' do
    let (:stderr) { '' }
    let (:stdout) { '' }

    it 'should drop the repository when it exists' do
      allow(subject).to receive(:exist?).and_return(true)
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.drop
      expect(subject).to have_received(:run!).with('aptly repo drop docker-cookery-ubuntu-14.04')
    end
  end

  describe '#publish' do
    context 'repo not published' do
      let (:stderr) { '' }
      let (:stdout) { '' }

      it 'publishes the repo' do
        allow(subject).to receive(:published?).and_return(false)
        allow(subject).to receive(:run!).and_return(shell_out)
        subject.publish
        expect(subject).to have_received(:run!).with('aptly publish repo -distribution=ubuntu-14.04 -architectures=i386,amd64 docker-cookery-ubuntu-14.04 docker-cookery-ubuntu-14.04')
      end
    end

    context 'repo already published' do
      let (:stderr) { '' }
      let (:stdout) { '' }

      it 'drops a published repo if the repo is already published' do
        allow(subject).to receive(:published?).and_return(true)
        allow(subject).to receive(:run!).and_return(shell_out)
        subject.publish
        expect(subject).to have_received(:run!).with('aptly publish drop ubuntu-14.04 docker-cookery-ubuntu-14.04')
      end
    end
  end

  describe '#add_package' do
    context 'package does not exist in repo' do
      let (:stderr) { '' }
      let (:stdout) { '' }

      it 'adds the package to the repo' do
        allow(subject).to receive(:package_exist?).and_return(false)
        allow(subject).to receive(:run!).and_return(shell_out)
        subject.add_package(package_path)
        expect(subject).to have_received(:run!).with("aptly repo add docker-cookery-ubuntu-14.04 #{package_path}")
      end
    end

    context 'package exists in repo' do
      let (:stderr) { '' }
      let (:stdout) { '' }

      it 'removes the package from the repo if it exists' do
        allow(subject).to receive(:package_exist?).and_return(true)
        allow(subject).to receive(:run!).and_return(shell_out)
        allow(subject).to receive(:rm_package)
        subject.add_package(package_path)
        expect(subject).to have_received(:rm_package).with(package)
      end
    end
  end

  describe '#rm_package' do
    let (:stderr) { '' }
    let (:stdout) { '' }

    it 'removes the package from the repository' do
      allow(subject).to receive(:package_exist?).and_return(true)
      allow(subject).to receive(:run!).and_return(shell_out)
      subject.rm_package(package)
      expect(subject).to have_received(:run!).with("aptly repo remove docker-cookery-ubuntu-14.04 #{package}")
    end
  end

  describe '#package_name_from_path' do
    it 'derives the package name from a filesystem path' do
      expect(subject.send(:package_name_from_path, package_path)).to eq package
    end
  end
end
