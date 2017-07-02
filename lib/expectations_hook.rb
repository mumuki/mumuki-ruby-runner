require 'mulang/ruby'

class RubyExpectationsHook < Mumukit::Templates::MulangExpectationsHook

  def language
    'Mulang'
  end

  def compile_content(source)
    Mulang::Ruby.parse(source)
  end

end
