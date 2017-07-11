require 'mulang/ruby'

class RubyExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  include_smells true

  def language
    'Mulang'
  end

  def compile_content(source)
    Mulang::Ruby.parse(source)
  rescue => e
    raise Mumukit::CompilationError, e
  end

end
