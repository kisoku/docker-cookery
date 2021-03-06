require 'docker-cookery/config'
require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'

module DockerCookery
  class ImageBuilder
    include Shellout

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def config
      DockerCookery::Config
    end

    def build_cmd
      cmd = "docker build -t #{config.docker_org}/#{name}"
      cmd << " --rm=#{config.rm?}"
      cmd << " --no-cache=#{config.force?}"
      cmd << " #{self.class.docker_dir}/#{name}"
      cmd
    end

    def build
      if dockerfile_exist?
        run!(build_cmd, {live_stream: STDOUT, timeout: config.timeout})
      else
        Log.puts "image #{name} does not exist in docker_dir #{self.class.docker_dir}"
        exit 1
      end
    end

    def dockerfile_exist?
      File.exist?(File.join(self.class.docker_dir, name, 'Dockerfile'))
    end

    class << self
      def find_all
        Dir.glob("#{docker_dir}/*/Dockerfile").map {|i| i.split('/')[-2] }.sort
      end

      def docker_dir
        userdir = File.expand_path('~/.docker-cookery/docker')
        if Dir.exist? userdir
          userdir
        else
          File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), '../../docker'))
        end
      end
    end
  end
end
