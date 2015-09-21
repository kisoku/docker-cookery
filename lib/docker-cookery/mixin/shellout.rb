require 'mixlib/shellout'
require 'mixlib/shellout/exceptions'

module DockerCookery
  module Shellout
    def run(*args)
      cmd = Mixlib::ShellOut.new(*args)
      cmd.run_command
      cmd
    end

    def run!(*args)
      cmd = run(*args)
      cmd.error!
      cmd
    end
  end
end
