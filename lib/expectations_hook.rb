require 'mulang/ruby'

class RubyExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  include_smells true

  def language
    'Mulang'
  end

  def original_language
    'Ruby'
  end

  def compile_content(source)
    Mulang::Ruby.parse(source)
  rescue => e
    raise Mumukit::CompilationError, e
  end

  def default_smell_exceptions
    LOGIC_SMELLS + FUNCTIONAL_SMELLS + %w(HasWrongCaseBindings)
  end

  def domain_language
    {
      caseStyle: 'RubyCase',
      minimumIdentifierSize: 3,
      jargon: []
    }
  end
end
