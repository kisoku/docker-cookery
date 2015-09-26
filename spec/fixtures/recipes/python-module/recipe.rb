class PythonModule < FPM::Cookery::PythonRecipe
  name 'python-module'
  description 'make sure we can load all kinds of fpm-cookery recipes'
  version '0.0.1'
  revision '1'

  depends 'bash'

  def build
  end

  def install
  end
end
