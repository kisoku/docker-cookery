require_relative '../spec_helper.rb'

describe DockerCookery::Shellout do
  subject { Class.new { include DockerCookery::Shellout }.new }

  describe '#run!' do
    it 'executes commands' do
      expect(subject.run!('echo -n foo').stdout).to eq 'foo'
    end

    it 'raises an exception on command failure' do
      expect { subject.run!('false') }.to raise_exception Mixlib::ShellOut::ShellCommandFailed
    end
  end
end
