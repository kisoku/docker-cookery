require_relative '../spec_helper.rb'

describe DockerCookery::PackageBuilder do
  let (:status) { double('Process::Status', :exitstatus => exitstatus) }
  let (:exitstatus) { 0 }
  let (:shell_out) { double('Mixlib::ShellOut', :status => status, :stdout => stdout, :stderr => stderr) }
  let (:stderr) { '' }
  let (:stdout) { '' }
  let (:package) { 'foo' }
  let (:platform) { 'ubuntu-14.04'}
  let (:recipe_path) { File.join('spec', 'fixtures', 'recipes') }
  let (:repo_path) { '/repo' }
  let (:shellout_options) { { live_stream: STDOUT, timeout: subject.config.timeout } }

  subject { DockerCookery::PackageBuilder.new(package, platform, recipe_path) }

  describe '#repo' do
    context 'returns a repo object' do
      it { expect(subject.repo).to be_a(DockerCookery::Repo::Aptly) }
    end
  end

  describe '#package_dir' do
    context 'returns a package_dir' do
      it { expect(subject.package_dir).to eq(File.expand_path(File.join(recipe_path, package))) }
    end
  end

  describe '#wants_to_build?' do
    context 'returns true when force? is set' do
      before do
        allow(DockerCookery::Config).to receive(:force?).and_return true
      end
      it { expect(subject.wants_to_build?).to be_truthy }
    end

    context 'returns true when the package does not exist in the repo' do
      before do
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:package_exist?).and_return(false)
      end
      it { expect(subject.wants_to_build?).to be_truthy }
    end

    context 'returns false when the package exists in the repo' do
      before do
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:package_exist?).and_return(true)
      end
      it { expect(subject.wants_to_build?).to be_falsey }
    end
  end

  describe '#build' do
    context 'builds a package with docker' do
      before do
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:path).and_return(repo_path)
        allow(subject).to receive(:wants_to_build?).and_return(true)
        allow(subject).to receive(:run!).and_return(shell_out)
        allow(subject).to receive(:publish)
      end

      it do
        subject.build
        expect(subject).to have_received(:run!).with(subject.build_cmd, shellout_options)
      end
    end

    context 'build package with extra options' do
      let (:environment) { [ 'FOO=1', 'BAR=2]' ] }
      let (:volumes) { [ '/foo:/foo' ] }

      before do
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:path).and_return(repo_path)
        allow(subject).to receive(:wants_to_build?).and_return(true)
        allow(DockerCookery::Config).to receive(:environment).and_return(environment)
        allow(DockerCookery::Config).to receive(:volumes).and_return(volumes)
        allow(subject).to receive(:run!).and_return(shell_out)
        allow(subject).to receive(:publish)
      end

      it do
        subject.build
        expect(subject).to have_received(:run!).with(subject.build_cmd, shellout_options)
      end
    end

    context 'does not build if package exists' do
      before do
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:path).and_return(repo_path)
        allow(subject).to receive(:wants_to_build?).and_return(false)
      end

      it do
        subject.build
        expect(subject).not_to receive(:build)
      end
    end
  end

  describe '#local_depends' do
    let(:package) { 'bar' }
    subject { DockerCookery::PackageBuilder.new(package, platform, recipe_path).local_depends }
    it { is_expected.to contain_exactly('foo') }
  end

  describe '#publish' do
    context 'it publishes packages after they are built' do
      let (:package_files) { [
        "packages/#{subject.repo.distribution}/#{subject.package}*#{subject.recipe.version}*#{subject.repo.package_suffix}"
      ] }

      before do
        allow(Dir).to receive(:glob).and_return(package_files)
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:exist?).and_return(false)
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:add_package)
        allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:publish)
      end

      it do
        subject.publish
        expect(subject.repo).to have_received(:add_package).with(package_files.first)
      end
    end

    context 'it raises SystemExit if no packages are found' do
      let (:package_files) { [] }

      before do
        allow(Dir).to receive(:glob).and_return(package_files)
      end

      it { expect { subject.publish }.to raise_exception SystemExit }
    end
  end
end
