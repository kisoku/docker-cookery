require_relative '../spec_helper.rb'

describe DockerCookery::BuildManager do
  let (:stamp_dir) { '/tmp/docker-cook-deadbeef' }
  let (:package) { 'foo' }
  let (:platform) { 'ubuntu-14.04'}
  let (:recipe_dir) { File.join('spec', 'fixtures', 'recipes') }
  let (:queue) { subject.send(:create_build_queue, package) }

  subject { DockerCookery::BuildManager.new(package, platform, recipe_dir) }

  describe '#repo' do
    it 'returns a repo object' do
      expect(subject.repo).to be_a(DockerCookery::Repo::Aptly)
    end
  end

  describe '#stampdir' do
    it 'creates a stampdir' do
      allow(Dir).to receive(:mktmpdir)
      subject.stamp_dir
      expect(Dir).to have_received(:mktmpdir).with('docker-cook')
    end
  end

  describe '#build' do
    before do
      allow_any_instance_of(DockerCookery::Repo::Aptly).to receive(:create)
      allow_any_instance_of(DockerCookery::PackageBuilder).to receive(:build)
      allow(FileUtils).to receive(:rm_rf)
      allow(FileUtils).to receive(:touch)
    end

    context 'it builds a queue of packages' do
      it do
        allow(subject).to receive(:stamp_dir).and_return(stamp_dir)
        allow(subject).to receive(:build_package)
        subject.build
        expect(subject).to have_received(:build_package)
      end
    end
  end

  describe '#create_build_queue' do
    context 'build queue for a package with no deps' do
      it { expect(queue.length).to eq 1 }
    end

    context 'build queue for a package with simple deps' do
      let (:package) { 'bar' }

      it { expect(queue.length).to eq 2 }
      it { expect(queue.first.recipe.name). to eq 'foo' }
      it { expect(queue.last.recipe.name). to eq 'bar' }
    end

    context 'build queue for a package with complex deps' do
      let (:package) { 'complex-a' }

      it { expect(queue.length).to eq 5 }
      it { expect(queue.length == queue.uniq.length).to be_truthy }
    end
  end

  describe '#build_package' do
    let (:package_builder) { DockerCookery::PackageBuilder.new(package, platform, recipe_dir) }
    let (:mock_pkg_builder) { double DockerCookery::PackageBuilder }

    before do
      allow(FileUtils).to receive(:touch)
      allow(File).to receive(:exist?).and_return(false)
      allow_any_instance_of(DockerCookery::PackageBuilder).to receive(:has_gemfile?).and_return(false)
      allow_any_instance_of(DockerCookery::PackageBuilder).to receive(:build)
      allow(FileUtils).to receive(:touch)
    end

    context 'checks to see if the stamp exists' do
      it do
        allow(subject).to receive(:stamp_dir).and_return(stamp_dir)
        allow(mock_pkg_builder).to receive(:stamp_name).and_return("#{package}-1.0.0-1")
        allow(mock_pkg_builder).to receive(:build)
        subject.send(:build_package, mock_pkg_builder)
        expect(File).to have_received(:exist?).with(File.join(stamp_dir, "#{package}-1.0.0-1"))
      end
    end

    context 'builds package if stamp is missing' do
      it do
        allow(subject).to receive(:stamp_dir).and_return(stamp_dir)
        allow(File).to receive(:exist?).and_return(false)
        subject.send(:build_package, package_builder)
        expect(package_builder).to have_received(:build)
      end
    end

    context 'does not build package if stamp is present' do
      it do
        allow(subject).to receive(:stamp_dir).and_return(stamp_dir)
        allow(File).to receive(:exist?).and_return(true)
        allow(package_builder).to receive(:build)
        subject.send(:build_package, package_builder)
        expect(package_builder).not_to have_received(:build)
      end
    end
  end
end
