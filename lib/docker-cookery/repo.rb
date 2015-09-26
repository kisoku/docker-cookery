require 'fileutils'
require 'json'

require 'docker-cookery/repo/aptly'
require 'docker-cookery/repo/createrepo'

module DockerCookery
  class Repo
    def self.new(name, prefix='fpm-recipes')
      case name
      when /ubuntu|debian/
        Aptly.new(name, prefix)
      when /centos|redhat/
        CreateRepo.new(name, prefix)
      end
    end
  end
end
