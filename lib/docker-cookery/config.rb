require 'mixlib/config'

module DockerCookery
  module Config
    extend Mixlib::Config

    config_strict_mode true
    default :debug?, false
    default :environment, []
    default :force?, false
    default :rm?, true
    default :recipe_path, Dir.pwd
    default :prefix, 'docker-cookery'
    default :timeout, 4800
    default :volumes, []

  end
end
