class Foo < FPM::Cookery::Recipe

  name 'foo'
  description 'foo sure maing'
  version '0.0.1'
  revision '1'

  depends 'bash'

  def build
  end

  def install
  end
end
