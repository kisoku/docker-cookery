require_relative '../../spec_helper'

describe DockerCookery::Repo::Base do
  let (:platform) { 'badcoffee' }

  subject { DockerCookery::Repo::Base.new(platform) }

  describe '#package_suffix' do
    subject { DockerCookery::Repo::Base.new(platform).package_suffix }
    context 'debian' do
      let (:platform) { 'debian-7' }
      it { is_expected.to eq 'deb' }
    end

    context 'ubuntu' do
      let (:platform) { 'ubuntu-14.04' }
      it { is_expected.to eq 'deb' }
    end

    context 'centos' do
      let (:platform) { 'centos-7' }
      it { is_expected.to eq 'rpm' }
    end

    context 'unknown' do
      it { is_expected.to eq '*' }
    end
  end

  describe '#path' do
    it 'throws not_implemented' do
      expect { subject.path }.to raise_exception(NotImplementedError)
    end
  end

  describe '#exist?' do
    it 'throws not_implemented' do
      expect { subject.exist? }.to raise_exception(NotImplementedError)
    end
  end

  describe '#published?' do
    it 'throws not_implemented' do
      expect { subject.published? }.to raise_exception(NotImplementedError)
    end
  end

  describe '#package_exist?' do
    it 'throws not_implemented' do
      expect { subject.package_exist?('bar') }.to raise_exception(NotImplementedError)
    end
  end

  describe '#create' do
    it 'throws not_implemented' do
      expect { subject.create }.to raise_exception(NotImplementedError)
    end
  end

  describe '#drop' do
    it 'throws not_implemented' do
      expect { subject.drop }.to raise_exception(NotImplementedError)
    end
  end

  describe '#publish' do
    it 'throws not_implemented' do
      expect { subject.publish }.to raise_exception(NotImplementedError)
    end
  end

  describe '#add_package' do
    it 'throws not_implemented' do
      expect { subject.add_package('/long/path/to/nowhere') }.to raise_exception(NotImplementedError)
    end
  end

  describe '#rm_package' do
    it 'throws not_implemented' do
      expect { subject.rm_package('bar') }.to raise_exception(NotImplementedError)
    end
  end
end
