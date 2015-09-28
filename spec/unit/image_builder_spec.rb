require_relative '../spec_helper'

describe DockerCookery::ImageBuilder do
  let (:status) { double('Process::Status', :exitstatus => exitstatus) }
  let (:exitstatus) { 0 }
  let (:shell_out) { double('Mixlib::ShellOut', :status => status, :stdout => stdout, :stderr => stderr) }
  let (:stderr) { '' }
  let (:stdout) { '' }
  let (:image) { 'ubuntu-14.04' }
  let (:docker_dir) { '/dock_of_the_bay' }
  let (:dockerfiles) { [ "#{docker_dir}/ubuntu-14.04/Dockerfile" ] }

  describe '#build' do
    subject { DockerCookery::ImageBuilder.new(image) }

    context 'builds a docker image when Dockerfile exists' do
      before do
        allow(DockerCookery::ImageBuilder).to receive(:docker_dir).and_return(docker_dir)
        allow_any_instance_of(DockerCookery::ImageBuilder).to receive(:dockerfile_exist?).and_return(true)
        allow_any_instance_of(DockerCookery::ImageBuilder).to receive(:run!).and_return(shell_out)
      end

      it do
        subject.build
        expect(subject).to have_received(:run!).with("docker build -t fpm_docker/#{subject.name} --rm=#{subject.config.rm?} --no-cache=#{subject.config.force?} #{docker_dir}/#{subject.name}", {live_stream: STDOUT, timeout: subject.config.timeout})
      end
    end

    context 'raises SystemExit when a Dockerfile does not exist' do
      before do
        allow(DockerCookery::ImageBuilder).to receive(:docker_dir).and_return(docker_dir)
        allow_any_instance_of(DockerCookery::ImageBuilder).to receive(:run!).and_return(shell_out)
      end

      it { expect { subject.build }.to raise_exception SystemExit }
    end
  end

  describe 'self#find_all' do
    subject { DockerCookery::ImageBuilder }

    context 'finds all Dockerfiles under docker_dir' do
      before do
        allow(Dir).to receive(:glob).and_return(dockerfiles)
      end
      it { expect(subject.find_all).to contain_exactly('ubuntu-14.04') }
    end
  end

  describe 'self#docker_dir' do
    subject { DockerCookery::ImageBuilder }

    context 'returns userdir if Dockerfiles are found there' do
      before do
        allow(Dir).to receive(:exist?).and_return(true)
      end
      it { expect(subject.docker_dir).to eq File.expand_path('~/.docker-cookery/docker') }
    end
  end
end
