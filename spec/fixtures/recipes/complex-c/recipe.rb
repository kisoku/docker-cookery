class ComplexC < FPM::Cookery::Recipe
  name 'complex-c'
  version '0.0.1'
  revision '1'

  depends 'complex-b'
  depends 'complex-d'
  depends 'complex-e'

  def build
  end

  def install
  end
end
