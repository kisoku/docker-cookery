require 'docker-cookery/log'
require 'docker-cookery/mixin/shellout'

module DockerCookery
  class ImageBuilder
    include Shellout

    attr_accessor :name, :config

    def initialize(name, config = {force: false, rm: true})
      @name = name
      @config = config
    end

    def build
      cmd = "docker build -t fpm_docker/#{name}"
      cmd << " --rm=#{config[:rm]}"
      cmd << " --no-cache=#{config[:force]}"
      cmd << " #{self.class.docker_dir}/#{name}"
      if dockerfile_exist?
        run!(cmd, {live_stream: STDOUT})
      else
        puts "image #{name} does not exist in docker_dir #{self.class.docker_dir}"
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
