class Bar < FPM::Cookery::Recipe

  name 'bar'
  description 'a man walks into a bar and says ouch'
  version '1.1.1'
  revision '1'

  depends 'zsh'
  build_depends 'foo'

  def build
  end

  def install
  end
end
